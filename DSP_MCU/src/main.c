/**
 * \file
 *
 * \brief Empty user application template
 *
 */



/*
 * Include header files for all drivers that have been imported from
 * Atmel Software Framework (ASF).
 */

#include <asf.h>

#include "FreeRTOS.h"
#include "task.h"
#include "ADXL345.h"

/*usart master module*/
struct usart_module usart_master_module;

/*I2C module*/
struct i2c_master_module i2c_master;
struct i2c_master_packet data_packet;

/*function definition*/
static void usart_config_setup(void);
static void i2c_set_config(void);

/*task handles*/
xTaskHandle uart_task_handle;

/*task handler prototypes*/
static void uart_task_handler(void* parameters);

/*sensor structure*/
ADXL_345 acc_sensor;


int main (void)
{
	system_init();
	
	/*config usart module sercom 4*/
	usart_config_setup();
	
	/*config i2c module sercom 0*/
	i2c_set_config();
	
	/*initialize the Accelerometer*/
	uint8_t err = ADXL345_init(&acc_sensor, &i2c_master, &data_packet);
	if(err != 0){
		while(1);
	}
	
	/* create task */
	portBASE_TYPE status;
	
	status = xTaskCreate(uart_task_handler, "UART_task",200,NULL,2,&uart_task_handle);
	configASSERT(status == pdPASS);
	
	/*start the freeRTOS scheduler*/
	vTaskStartScheduler();
	
	while (1) {
	}
}

/*  usart task priority 3*/
static void uart_task_handler(void* parameters){
	
	const portTickType xDelay = 100 / portTICK_RATE_MS;
	portTickType lastwakeup = xTaskGetTickCount();
	
	status_code_genare_t status_tx_check = STATUS_OK;
	
	uint16_t rx_buffer = 0;
	
	while(1){

		/*Get Data from accelerometer sensor*/
		ADXL345_get_data(&acc_sensor);
				
		status_tx_check = usart_write_wait(&usart_master_module,acc_sensor.acc_raw[0]);
		
		if(status_tx_check != STATUS_OK){
			while(1);
		}
		
		status_tx_check = usart_read_wait(&usart_master_module,&rx_buffer);
		
		if(status_tx_check != STATUS_OK){
			while(1);
		}
		
		
		vTaskDelayUntil(&lastwakeup,xDelay);	
	}
}


static void i2c_set_config(void){
	status_code_genare_t status_check = STATUS_OK;
	
	/*setup the i2c configurations*/
	struct i2c_master_config i2c_config;
	
	/*set default values for the structure*/
	i2c_master_get_config_defaults(&i2c_config);
	
	/* define the pins for sercom*/
	i2c_config.pinmux_pad0 = PINMUX_PA08C_SERCOM0_PAD0; //SDA
	i2c_config.pinmux_pad1 = PINMUX_PA09C_SERCOM0_PAD1; //SCL
	
	/*write the configuration to master module*/
	status_check = i2c_master_init(&i2c_master,SERCOM0,&i2c_config);
	if( status_check != STATUS_OK){
		while(1){
			printf("Could not initialize i2c\n");
		}
	}

	/*enable i2c in master mode*/
	i2c_master_enable(&i2c_master);

}

static void usart_config_setup(void){
	status_code_genare_t status_check = STATUS_OK;

	struct usart_config usart_setup;
	usart_get_config_defaults(&usart_setup);
	//configure pins and pinmux for sercom 4
	usart_setup.mux_setting = USART_RX_3_TX_2_XCK_3;
	usart_setup.pinmux_pad2 = PINMUX_PB10D_SERCOM4_PAD2;
	usart_setup.pinmux_pad3 = PINMUX_PB11D_SERCOM4_PAD3;
	usart_setup.baudrate = 115200;
	// write the configuration to the master module
	status_check = usart_init(&usart_master_module, SERCOM4 ,&usart_setup);
	if(status_check != STATUS_OK){
		while(1){
			;
		}
	}
	//enable the usart
	usart_enable(&usart_master_module);
}