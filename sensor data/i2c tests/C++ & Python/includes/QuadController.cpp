#include <bits/stdc++.h> 
#include "unixFunctions.hpp"
using namespace std; 

class Vector3D{
  public:
   float x;
   float y;
   float z;
   Vector3D(float x, float y, float z) : x(x),y(y),z(z){}
};

class Vector4D{
  public:
   float x;
   float y;
   float z;
   float w;
   Vector4D(float x, float y, float z,float w) : x(x),y(y),z(z),w(w){}
};

class QuadController{
	
	private:
	
	class controller { 
		private:
		
		float Kp;
		float Ki;
		float Kd;
		
		float error=0;
		float previousError=0;
		float integral=0;
		float derivative=0;

		int last_time=0;
		
		public: 
		
		float current=0;
		float target=0;
		float output=0;

		controller(float Kp,float Ki,float Kd) : Kp(Kp), Ki(Ki), Kd(Kd) {}
		
		void calc(){
			int current_time = micros();
			float dt=0;
			dt = (current_time - last_time)/1000.0/1000.0;//dt in seconds
			//printf("%f  \n",dt);
			last_time=current_time;

			error = (target - current)/3.1415/2; //normalize: 2pi error => 1
			integral = integral + error*dt;
			derivative = (error - previousError)/dt;
			output = (Kp*error + Ki*integral + Kd*derivative);
		  previousError = error;
		}
	}; 
	
  const float steerConst=1;

  const float rotKp=50; //initial 50
  const float rotKi=0;
  const float rotKd=40; //initial 10

  const float posKp=10;
  const float posKi=0;
  const float posKd=8;

  const int scalar=5;
	//                   R  P  Y  X  Y  Z
  const int coeff[4][6]= {{ -1, 1, 1, 1, 1, 1}, //FL
			  {  1, 1,-1, 1,-1, 1}, //FR
			  { -1,-1,-1,-1, 1, 1}, //BL
			  {  1,-1, 1,-1,-1, 1}};//BR
			
	controller* rollCtl;
	controller* pitchCtl;
	controller* yawCtl;
	controller* XCtl;
	controller* YCtl;
	controller* ZCtl;
	
	public:
    QuadController(){
      rollCtl = new controller(rotKp,rotKi,rotKd);
    	pitchCtl = new controller(rotKp,rotKi,rotKd);
    	yawCtl = new controller(rotKp,rotKi,rotKd);
    	XCtl = new controller(posKp,posKi,posKd);
    	YCtl = new controller(posKp,posKi,posKd);
    	ZCtl = new controller(posKp,posKi,posKd);
    } 
	
	/**
	 * calculate motor speeds by using an PID controllor on the inputs.
	 *
	 * This sum is the arithmetic sum, not some other kind of sum that only
	 * mathematicians have heard of.
	 *
	 * @param rot current orientation, Vector containing Euler-angles (x=roll,y=pitch,z=yaw, 0 to 2pi)
	 * @param input user steering input (x=roll,y=pitch,z=yaw,w=power, -1 to 1)
	 * @param pos current position, Vector
	 * @param targetPos position to be moved to, ignored if obmitted or NULL
	 *
	 * @return array of motor speeds.
	 */
    float (&run(Vector3D* rot,Vector4D* input,Vector3D* pos=NULL,Vector3D* targetPos=NULL))[4]{	
        rollCtl->target=steerConst*input->x;
        pitchCtl->target=steerConst*input->y;
        yawCtl->target=steerConst*input->z;
        rollCtl->current=rot->x;
        pitchCtl->current=rot->y;
        yawCtl->current=rot->z;
        

        rollCtl->calc();
        pitchCtl->calc();
        yawCtl->calc();
        
        if (targetPos!=NULL){
            XCtl->target=targetPos->x;
            YCtl->target=targetPos->y;
            ZCtl->target=targetPos->z;
            
            XCtl->current=pos->x;
            YCtl->current=pos->y;
            ZCtl->current=pos->z;
            
            XCtl->calc();
            YCtl->calc();
            ZCtl->calc();
        }
        static float output[]={0,0,0,0};

        for (int i=0;i<4;i++){
            output[i]=             coeff[i][0]*rollCtl->output + coeff[i][1]*pitchCtl->output + coeff[i][2]*yawCtl->output;
            output[i]=output[i] +  coeff[i][3]*XCtl->output    + coeff[i][4]*YCtl->output     + coeff[i][5]*ZCtl->output;
	    output[i]*=scalar;
	    output[i]+=50;
            output[i]=output[i]*input->w;

            if (output[i]<0)  output[i]=0;
            if (output[i]>100)output[i]=100;
        }
        
        delete rot;
        delete input;
        delete pos;
        delete targetPos;
        
        return output;
	}
};
