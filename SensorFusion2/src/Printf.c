/**************************************************************************//**
* @file      printf.h 
* @brief     
* @author    Tarush Sharma 
* @date      05-04-2024

******************************************************************************/


/******************************************************************************
* Includes
******************************************************************************/
#include "printf.h"

/******************************************************************************
* Defines
******************************************************************************/

/******************************************************************************
* Variables
******************************************************************************/

/******************************************************************************
* Forward Declarations
******************************************************************************/
void configure_console(void)
 {
	 struct usart_config usart_conf;
	 usart_get_config_defaults(&usart_conf);
	 usart_conf.mux_setting = EDBG_CDC_SERCOM_MUX_SETTING;
	 usart_conf.pinmux_pad0 = EDBG_CDC_SERCOM_PINMUX_PAD0;
	 usart_conf.pinmux_pad1 = EDBG_CDC_SERCOM_PINMUX_PAD1;
	 usart_conf.pinmux_pad2 = EDBG_CDC_SERCOM_PINMUX_PAD2;
	 usart_conf.pinmux_pad3 = EDBG_CDC_SERCOM_PINMUX_PAD3;
	 usart_conf.baudrate    = 115200;

	 stdio_serial_init(&usart_instance, EDBG_CDC_MODULE, &usart_conf);
	 usart_enable(&usart_instance);
 }
 
/******************************************************************************
* Callback Functions
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