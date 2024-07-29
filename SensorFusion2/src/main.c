/**
 * \file
 *
 * \brief Empty user application template
 *
 */

/**
 * \mainpage User Application template doxygen documentation
 *
 * \par Empty user application template
 *
 * This is a bare minimum user application template.
 *
 * For documentation of the board, go \ref group_common_boards "here" for a link
 * to the board-specific documentation.
 *
 * \par Content
 *
 * -# Include the ASF header files (through asf.h)
 * -# Minimal main function that starts with a call to system_init()
 * -# Basic usage of on-board LED and button
 * -# "Insert application code here" comment
 *
 */

/*
 * Include header files for all drivers that have been imported from
 * Atmel Software Framework (ASF).
 */
/*
 * Support and FAQ: visit <a href="https://www.microchip.com/support/">Microchip Support</a>
 */
#include <asf.h>

#include "Printf.h"
#include "FIR_Filter.h"
#include "ADXL345.h"


/*I2C structures*/
struct i2c_master_module i2c_master;
struct i2c_master_packet data_packet;

/*Timer structures*/
struct tcc_module tcc_instance;

/*Filtered acc values*/

float filt_acc[3] = {0,0,0};

ADXL_345 acc_sensor;
FIR_Filter LowPass_z;

static void i2c_set_config(void);
static void configure_tcc(void);
static void usart_configure(void);

static void tcc_callback(struct tcc_module *const module_inst){
		
		/*Get Data from accelerometer sensor*/
		ADXL345_get_data(&acc_sensor);	
		
		/*update FIR filter*/
		filt_acc[2] = FIR_update(&LowPass_z, acc_sensor.acc_mps[2]);
		//int intpp = (int)z;
		//int decc = (int)((z - intpp)*10);
		//
		//int intp = (int)acc_sensor.acc_mps[2];
		//int dec = (int)((acc_sensor.acc_mps[2] - intp)*10);
		//printf("%d.%d   ---  %d.%d\r\n",intp,dec,intpp,decc);
}
 
int main (void)
{
	system_init();

	/* Insert application code here, after the board has been initialized. */

	/* Configure USART console for printf debugging*/
	configure_console();
	printf(" Debugging Check\r\n");
	
	/*Configure the !2C module to be used by accelerometer*/
	i2c_set_config();
	/*Setup the timer to trigger a callback every 1 ms*/
	configure_tcc();
	tcc_register_callback(&tcc_instance, tcc_callback,TCC_CALLBACK_OVERFLOW);
	tcc_enable_callback(&tcc_instance, TCC_CALLBACK_OVERFLOW);

	/*initialize the Accelerometer*/
	uint8_t err = ADXL345_init(&acc_sensor, &i2c_master, &data_packet);
	if(err == 0){
		printf(" Successfully Initialized Accelerometer ADXL345 \r\n");
	}	
	
	/*Initialize FIR filer*/
	FIR_filter_init(&LowPass_z);
	
	while (1) {
		
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

static void configure_tcc(void){
	
	struct tcc_config config_tcc;
	tcc_get_config_defaults(&config_tcc, TCC0);
	config_tcc.counter.clock_source = GCLK_GENERATOR_1;
	config_tcc.counter.clock_prescaler = TCC_CLOCK_PRESCALER_DIV64;
	config_tcc.counter.period = 5;
	tcc_init(&tcc_instance, TCC0, &config_tcc);
	tcc_enable(&tcc_instance);
}
