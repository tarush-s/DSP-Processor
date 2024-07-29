/**************************************************************************//**
* @file      FIR_Filter.c
* @brief     
* @author    Tarush Sharma 
* @date      05-04-2024

******************************************************************************/


/******************************************************************************
* Includes
******************************************************************************/
#include "FIR_Filter.h"

/******************************************************************************
* Defines
******************************************************************************/

/******************************************************************************
* Variables
******************************************************************************/
/*

FIR filter designed with
http://t-filter.appspot.com

sampling frequency: 100 Hz

* 0 Hz - 10 Hz
  gain = 1
  desired ripple = 5 dB
  actual ripple = 2.3133909166191504 dB

* 20 Hz - 50 Hz
  gain = 0
  desired attenuation = -40 dB
  actual attenuation = -45.01618674525617 dB

*/


static double impulse_response[FIR_FILTER_LENGTH] = {
  -0.01259277478717816,
  -0.02704833486706803,
  -0.031157016036431583,
  -0.003351666747179282,
  0.06651710329324828,
  0.1635643048779222,
  0.249729473226146,
  0.2842779082622769,
  0.249729473226146,
  0.1635643048779222,
  0.06651710329324828,
  -0.003351666747179282,
  -0.031157016036431583,
  -0.02704833486706803,
  -0.01259277478717816
};

/******************************************************************************
* Forward Declarations
******************************************************************************/

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
void FIR_filter_init(FIR_Filter *obj){

    /* Clear the filter buffer*/
    for(uint8_t i = 0; i < FIR_FILTER_LENGTH; i++){
        obj->buffer[i] = 0;
    }

    /*Reset the buffer index to 0*/
    obj->buffer_index = 0;

    /*Clear the filter output*/
    obj->output = 0;
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
float FIR_update(FIR_Filter *obj, float input){

    /*Store the input */
    obj->buffer[obj->buffer_index] = input;

    /*increment the buffer index*/
    obj->buffer_index++;
    if(obj->buffer_index == FIR_FILTER_LENGTH){
        obj->buffer_index = 0;
    }

    /*clear the output and compute new output */
    obj->output = 0;
    uint8_t index = obj->buffer_index;

    for(uint8_t i = 0; i < FIR_FILTER_LENGTH; i++){
        
		if(index > 0){
            index--;
        }
        else {
            index = FIR_FILTER_LENGTH - 1;
        }

        /*Multiply the impulse response with input*/
        obj->output += impulse_response[i] * obj->buffer[index];
    }

    return obj->output;
}