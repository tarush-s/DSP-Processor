/**************************************************************************//**
* @file      ADXL345.h
* @brief     
* @author    Tarush Sharma 
* @date      2024-05-05

******************************************************************************/

#pragma once
#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
* Includes
******************************************************************************/
#include <asf.h>

/******************************************************************************
* Defines
******************************************************************************/
#define ADXL345_ADR 0x53
#define ADXL345_ID 0xE5

/*4mg per lSB*/
#define MGM2G_VALUE 0.0039 

/*registers*/
#define ADXL345_ID_REG 0x00
#define ADXL345_POWER_CNTRL 0x2D
#define ADXL345_DATA_FORMAT 0x31
#define ADXL_345_BW 0x2C
#define ADXL_345_INT_ENABLE 0x2E
#define ADXL_345_INT_MAP 0x2F
#define ADXL_345_INT_SRC 0x30
#define ADXL345_DATAX0 0x32
#define ADXL345_DATAX1 0x33
#define ADXL345_DATAY0 0x34
#define ADXL345_DATAY1 0x35
#define ADXL345_DATAZ0 0x36
#define ADXL345_DATAZ1 0x37
/******************************************************************************
* Structures and Enumerations
******************************************************************************/
/*Sensor struct */

typedef struct {
	/*Acceleration raw values*/
	int16_t acc_raw[3];
    /* Acceleration Data */
    float acc_mps[3];
    /*I2C struct*/
    struct i2c_master_module *i2c_master;
    /*I2C Data packet*/
	struct i2c_master_packet *master_packet;

} ADXL_345;


/******************************************************************************
* Global Function Declaration
******************************************************************************/
/*Initialization Function*/
uint8_t ADXL345_init(ADXL_345 *sensor, struct i2c_master_module *i2c_handler, struct i2c_master_packet *packet_handler);

/*Data acquisition Function*/
status_code_genare_t ADXL345_get_data(ADXL_345 *sensor);

/*Low level functions */
status_code_genare_t ADXL345_ReadRegister(ADXL_345 *sensor, uint8_t reg, uint8_t *rx_data, uint16_t length);
status_code_genare_t ADXL345_WriteRegister(ADXL_345 *sensor, uint8_t reg, uint8_t *tx_data, uint16_t length);

#ifdef __cplusplus
}
#endif