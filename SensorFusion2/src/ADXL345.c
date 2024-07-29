/**************************************************************************//**
* @file      ADXL345.c
* @brief     
* @author    Tarush Sharma 
* @date      2024-05-05
******************************************************************************/


/******************************************************************************
* Includes
******************************************************************************/
#include <asf.h>

#include "ADXL345.h"

/******************************************************************************
* Defines
******************************************************************************/

/******************************************************************************
* Variables
******************************************************************************/



/**************************************************************************//**
* @fn		int ExampleFuncionComment(int inputInt, void *pvParameters)
* @brief	An example function comment. Erase me!
* @details 	Write details of function here.
                				
* @param[in]	InputInt Use me to describe inputs to functions
* @param[out]	*pvParameters Use me to describe outputs of functions passed as arguments
* @return		Use me to explain the return of an argument.
* @note         
*****************************************************************************/
uint8_t ADXL345_init(ADXL_345 *sensor, struct i2c_master_module *i2c_handler, struct i2c_master_packet *packet_handler){
	
	/*Set the structure parameter*/
	sensor->i2c_master = i2c_handler;
	sensor->master_packet = packet_handler;
	
	/*Set Default values for the data packet*/
	sensor->master_packet->data_length = (uint16_t)1;
    sensor->master_packet->data = NULL;
	sensor->master_packet->address = ADXL345_ADR;
	sensor->master_packet->high_speed = false;	
	sensor->master_packet->ten_bit_address = false;
	
	/*Set default values for output parameter*/
	sensor->acc_mps[0] = 0;
	sensor->acc_mps[1] = 0;
	sensor->acc_mps[2] = 0;
	sensor->acc_raw[0] = 0;
	sensor->acc_raw[1] = 0;
	sensor->acc_raw[2] = 0;
	
	status_code_genare_t status_check = STATUS_OK;
	/*Counter to track errors*/
	uint8_t error = 0;
	
	/*check device ID */
	uint8_t rx_data;
	status_check = ADXL345_ReadRegister(sensor, ADXL345_ID_REG, &rx_data, 1);
	
	if(status_check != STATUS_OK){
		error++;
	}
	
	if(rx_data != ADXL345_ID){
		error++;
		return error;
	}
	
	/*Set the device to 100Hz data rate and select normal operation (low noise)*/
	uint8_t Reg_Data = 0x0A;
	status_check = ADXL345_WriteRegister(sensor, ADXL_345_BW, &Reg_Data, 1);
	
	if(status_check != STATUS_OK){
		error++;
	}
	
	/*Set the device in measurement mode*/
	Reg_Data = 0x08;
	status_check = ADXL345_WriteRegister(sensor, ADXL345_POWER_CNTRL, &Reg_Data, 1);
	
	if(status_check != STATUS_OK){
		error++;
	}
	
	
	
	return error;
}

/**************************************************************************//**
* @fn		int ExampleFuncionComment(int inputInt, void *pvParameters)
* @brief	An example function comment. Erase me!
* @details 	Write details of function here.
                				
* @param[in]	InputInt Use me to describe inputs to functions
* @param[out]	*pvParameters Use me to describe outputs of functions passed as arguments
* @return		Use me to explain the return of an argument.
* @note         
*****************************************************************************/
uint8_t ADXL345_get_data(ADXL_345 *sensor){
	
	status_code_genare_t status_check = STATUS_OK;
	uint8_t error = 0;
	
	uint8_t read_buffer[6] = {0,0,0,0,0,0};
	int16_t x = 0;
	int16_t y = 0;
	int16_t z = 0;	
	
	float x_acc = 0;
	float y_acc = 0;
	float z_acc = 0;
	
	/*For +- 2g range with 10 bit resolution*/
	/*Start reading the data register for the x axis and read 6 registers*/ 
	status_check = ADXL345_ReadRegister(sensor, ADXL345_DATAX0, read_buffer, 6);
	
	if(status_check != STATUS_OK){
		error++;
	}	
	
	/* x = ((ADXL345_DATAX1) << 8) + ADXL345_DATAX0 */
	x = ((int16_t)read_buffer[1] << 8) + read_buffer[0];
	/* y = ((ADXL345_DATAY1) << 8) + ADXL345_DATAY0 */
	y = ((int16_t)read_buffer[3] << 8) + read_buffer[2];
	/* z = ((ADXL345_DATAZ1) << 8) + ADXL345_DATAZ0 */
	z = ((int16_t)read_buffer[5] << 8) + read_buffer[4];
	
	/*Convert to proper resolution*/
	x_acc = x * MGM2G_VALUE; 
	y_acc = y * MGM2G_VALUE;
	z_acc = z * MGM2G_VALUE;

	/*Assign the raw sensor values*/
	sensor->acc_raw[0] = x;
	sensor->acc_raw[1] = y;
	sensor->acc_raw[2] = z;
	
	/*Assign the final sensor values*/
	sensor->acc_mps[0] = x_acc;
	sensor->acc_mps[1] = y_acc;
	sensor->acc_mps[2] = z_acc;
	
	return error;
	
}
/******************************************************************************
* low Level functions
******************************************************************************/

status_code_genare_t ADXL345_ReadRegister(ADXL_345 *sensor, uint8_t reg, uint8_t *rx_data, uint16_t length){
	
	sensor->master_packet->data_length = (uint16_t)1;
	sensor->master_packet->data = &reg;

	status_code_genare_t err = i2c_master_write_packet_wait_no_stop(sensor->i2c_master,sensor->master_packet);
	if(err != STATUS_OK){
		return err;
	}
	
	/* Delay between consecutive reads / writes */
	delay_us(25);
	
	sensor->master_packet->data_length = length;
	sensor->master_packet->data = rx_data;
	
	err = i2c_master_read_packet_wait(sensor->i2c_master,sensor->master_packet);
	
	/* Delay between consecutive reads / writes */
	delay_us(25);
	
	return err;
}
status_code_genare_t ADXL345_WriteRegister(ADXL_345 *sensor, uint8_t reg, uint8_t *tx_data, uint16_t length){
	
	/*Create a local buffer to combine register address and tx data*/
	uint8_t local_buffer[10];
	
	/*Add register address*/
	local_buffer[0] = reg;
	
	/*Copy tx buffer into our local buffer*/
	for(int i = 0; i < length; i++){
		local_buffer[i+1] = tx_data[i];
	}
	
	sensor->master_packet->data_length = (length + 1);
	sensor->master_packet->data = local_buffer;
	
	status_code_genare_t err = i2c_master_write_packet_wait(sensor->i2c_master,sensor->master_packet);
	
	/* Delay between consecutive reads / writes */
	delay_us(25);
	
	return err;

}