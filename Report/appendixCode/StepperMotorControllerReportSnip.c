#include "StepperMotorController.h" //Include constants such as angle pr. step etc.

void stepper_move_degs(int dir, double degrees)
{
    degrees = fabs(degrees); //stepperCountdown only accpets positive numbers
    if(degrees > 38 ) degrees = 38; //If angle is higher than (2^8)-1 * STEPPER_DEG_PER_STEP (which is 0.15) the input to stepper motor counter will overflow.
    
	//Calculate the number of full steps
    uint8_t full_steps_left = 0;
    full_steps_left = (uint8_t)degrees_to_fullsteps(degrees);
    
    stepperSteps_Write(full_steps_left); //Write to stepperSteps register
    stepperReset_Write(0xFF);            //Tell stepperCounter to read stepperSteps register
    Stepper_direction_Write(dir);        //Set direction of stepper motor
    stepperReset_Write(0x00);            //Tell stepperCounter to start
}

void StepperMotorController(double radian){
    int direction = (radian >= 0);
    stepper_move_degs(direction, radian * 180 / CY_M_PI); // CY_M_PI is the Cypress implementaion of pi.
}