#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/adc.h"

void gpio_callback(){
	gpio_put(5, true);
}

int main(void){
	stdio_init_all();
	// PIN25 = inchip LED; PIN5 = Beep; PIN2 = sound detector sensor; PIN3 = alarm setting; PIN4 = Bepp setting
	gpio_init_mask((1<<5) + (1<<25) + (1<<2) + (1<<3) +(1<<4));
	gpio_set_dir_masked((1<<5) + (1<<25) + (1<<2) + (1<<3) +(1<<4),(1<<5) + (1<<25) + (0<<2) + (0<<3) +(0<<4));

	//Setting Pull-down for input pins
	gpio_pull_down(2); //const DOWN
	gpio_pull_down(3);
	gpio_pull_down(4);
	//Enabling input pins
	gpio_set_input_enabled(3, true);
	gpio_set_input_enabled(4, true);

	//Configure ADC
	adc_init();
	adc_set_temp_sensor_enabled(true);
	//4 = inboard temperature sensor
	adc_select_input(4);
	uint16_t raw;
	const float conversion = 3.3f / (1<<12);
	float voltage;
	float temperature;

	while(1){
		sleep_ms(1000);
		//if beep mqtt is detected, then ring the alarm
		if(gpio_get(4)){
			sleep_ms(800);	//this delays serves as a double check if beep was really activated
			if(gpio_get(4)){
				gpio_put(5, true);
				gpio_put(25, false);
			}
		}
		//if alarm off
		else if(!gpio_get(3)) {
			gpio_set_input_enabled(2, false); //disable sound detector and ringing alarm
			gpio_set_irq_enabled_with_callback(2, GPIO_IRQ_EDGE_RISE|GPIO_IRQ_EDGE_FALL,false, &gpio_callback);
			gpio_put(5,false);
			gpio_put(25, false);
		}
		//setting the alarm
		else if(gpio_get(3)) {
			sleep_ms(400);
			if(gpio_get(3)){
				gpio_put(25,true);
				gpio_set_input_enabled(2,true);
				gpio_set_irq_enabled_with_callback(2, GPIO_IRQ_EDGE_RISE|GPIO_IRQ_EDGE_FALL,true, &gpio_callback);
			}
		}
		raw = adc_read();
		voltage = raw*conversion;
		temperature = 27 - (voltage - 0.706)/0.001721;
		printf("%f\n",temperature);
	}
}

