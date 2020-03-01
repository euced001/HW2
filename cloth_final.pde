//SOURCES
//For colors: https://www.rapidtables.com/web/color/purple-color.html
Camera camera;
int sphereRadius = 100;
int sphereX = 150;
int sphereY = 300;
int sphereZ = 150;
float xposition = mouseX;
float yposition = mouseY;
int numNodesX = 15;
int numNodesY = 15;
int xBallStart = 0;
int yBallStart = 30;
int zBallStart = 0;
int difference = 25;//60; //must be above restlength to start strechted out.
//Environment
float gravity = 50; //???
//Anchor
float restLength = 25;// 50;
float k = 30; //higher k means less stable/ more forces --> less stable
float kv = 10; //damping

//Ball Features
float radius = 10;
float mass = .2; //(keep mass low)

//Arrays
float [][] xBallPosit = new float[numNodesY][numNodesX];
float [][] yBallPosit = new float[numNodesY][numNodesX];
float [][] zBallPosit = new float[numNodesY][numNodesX];


float [][] xVel = new float[numNodesY][numNodesX];
float [][] yVel = new float[numNodesY][numNodesX];


float [][] xForce = new float[numNodesY][numNodesX];
float [][] yForce = new float[numNodesY][numNodesX];



void setup() {

  size(800, 800, P3D);
  surface.setTitle("Cloth;");
  //Set up anchor positions
  camera = new Camera();
  //Set up ball positions  
  for ( int i = 0; i < numNodesY; i++) {  
    for ( int j = 0; j < numNodesX; j++) {
      //xBallPosit[i][j] = xBallStart + j * 30 + i*5; 
      xBallPosit[i][j] = xBallStart + j*difference; 

      yBallPosit[i][j] = yBallStart; //yBallStart + i * difference;
      //zBallPosit[i][j] = zBallStart + 30;

      zBallPosit[i][j] = zBallStart + i*difference;


      xVel[i][j] = 10;
      yVel[i][j] = 0;

      if (i == 0)
        xVel[i][j] = 0;
    }
    xBallStart -=difference;
  }

}// setup
//Camera functions
void keyPressed()
{
  camera.HandleKeyPressed();
}

void keyReleased()
{
  camera.HandleKeyReleased();
}

void update(float dt) {


  for (int i = 0; i < numNodesY; i++) {

    for (int j = 0; j < numNodesX; j++) {  
      xForce[i][j] = 0;
      yForce[i][j] = gravity * mass;
    }
  }

  for (int i = 0; i < numNodesY-1; i++) {

    for (int j = 0; j < numNodesX; j++) {         

      float deltaX = xBallPosit[i+1][j] - xBallPosit[i][j];
      float deltaY = yBallPosit[i+1][j] - yBallPosit[i][j];

      float stringLength = sqrt(deltaX*deltaX + deltaY*deltaY);
      float stringForce = k*(stringLength - restLength); // This is the amount of the force.
      deltaX = deltaX / stringLength; 
      deltaY = deltaY / stringLength; 

      float ev1 = xVel[i][j]*deltaX+ yVel[i][j]*deltaY;
      float ev2 = xVel[i+1][j]*deltaX+ yVel[i+1][j]*deltaY;

      float dampF = -kv*(ev1 - ev2);
      //println( "dampF = ", dampF );

      xForce[i][j] += (stringForce + dampF)*deltaX;
      yForce[i][j] += (stringForce + dampF)*deltaY;


      xForce[i+1][j] += -(stringForce + dampF)*deltaX;
      yForce[i+1][j] += -(stringForce + dampF)*deltaY;
    } // j for loop
  }// i for loop


  for (int i = 0; i < numNodesY; i++) {

    for (int j = 0; j < numNodesX-1; j++) {         

      float deltaX = xBallPosit[i][j+1] - xBallPosit[i][j];
      float deltaY = yBallPosit[i][j+1] - yBallPosit[i][j];

      float stringLength = sqrt(deltaX*deltaX + deltaY*deltaY);
      float stringForce = k*(stringLength - restLength); // This is the amount of the force.
      deltaX = deltaX / stringLength; 
      deltaY = deltaY / stringLength; 

      float ev1 = xVel[i][j]*deltaX+ yVel[i][j]*deltaY;
      float ev2 = xVel[i][j+1]*deltaX+ yVel[i][j+1]*deltaY;

      float dampF = -kv*(ev1 - ev2);
      // println( "dampF = ", dampF );

      xForce[i][j] += (stringForce + dampF)*deltaX;
      yForce[i][j] += (stringForce + dampF)*deltaY;


      xForce[i][j+1] += -(stringForce + dampF)*deltaX;
      yForce[i][j+1] += -(stringForce + dampF)*deltaY;
    } // j for loop
  }// i for loop

  for (int j = 0; j < numNodesX; j++) {   
    xForce[0][j] = 0;
    yForce[0][j] = 0;
  }

  for (int i = 0; i < numNodesY; i++) {

    for (int j = 0; j < numNodesX; j++) {

      float xAcc = xForce[i][j] / mass;
      float yAcc = yForce[i][j] / mass;
      xVel[i][j] = xVel[i][j] + xAcc * dt;
      yVel[i][j] = yVel[i][j] + yAcc * dt;

      xBallPosit[i][j] =  xBallPosit[i][j] + xVel[i][j]*dt; 
      yBallPosit[i][j] = yBallPosit[i][j] + yVel[i][j] * dt;
    }
  }
}

void draw() {
  background(255, 255, 255);
  noLights();
  camera.Update( 0.005);
  for (int i = 0; i < 10; i++) {
    update(0.005);
    if(mousePressed)
      collisionDetect();
  }
  int strokeVal = 100;
  for (int i = 0; i < numNodesY-1; i++) {

    for (int j = 0; j < numNodesX-1; j++) {
      if ( i%2 ==0) {
        stroke(strokeVal);
        //fill(0, 0, 0, 100);
        fill(153,50,204, 75);
        pushMatrix();
        beginShape();
        vertex(xBallPosit[i][j], yBallPosit[i][j], zBallPosit[i][j]);
        vertex(xBallPosit[i+1][j], yBallPosit[i+1][j], zBallPosit[i+1][j]);
        vertex(xBallPosit[i+1][j+1], yBallPosit[i+1][j+1], zBallPosit[i+1][j+1]);
        vertex(xBallPosit[i][j+1], yBallPosit[i][j+1], zBallPosit[i][j+1]); 
        endShape(CLOSE);
        popMatrix();
      } else {   
        stroke(strokeVal);
        fill(255, 255, 255, 100);
        pushMatrix();
        beginShape();
        vertex(xBallPosit[i][j], yBallPosit[i][j],zBallPosit[i][j]);
        vertex(xBallPosit[i+1][j], yBallPosit[i+1][j], zBallPosit[i+1][j]);
        vertex(xBallPosit[i+1][j+1], yBallPosit[i+1][j+1], zBallPosit[i+1][j+1]);
        vertex(xBallPosit[i][j+1], yBallPosit[i][j+1], zBallPosit[i][j+1]); 
        endShape(CLOSE);
        popMatrix();
      }
    }
  }


  for (int i = 0; i < numNodesY-1; i++) {

    for (int j = 0; j < numNodesX-1; j++) {
      if ( j%2 ==0) {
        stroke(strokeVal);
        //fill(0, 0, 0, 100); 
        fill(153,50,204, 75);
        pushMatrix();
        beginShape();
        vertex(xBallPosit[i][j], yBallPosit[i][j], zBallPosit[i][j]);
        vertex(xBallPosit[i+1][j], yBallPosit[i+1][j], zBallPosit[i+1][j]);
        vertex(xBallPosit[i+1][j+1], yBallPosit[i+1][j+1], zBallPosit[i+1][j+1]);
        vertex(xBallPosit[i][j+1], yBallPosit[i][j+1], zBallPosit[i][j+1]); 
        endShape(CLOSE);
        popMatrix();
      } else {
        stroke(strokeVal);
        fill(255, 255, 255, 100); 
        pushMatrix();
        beginShape();
        vertex(xBallPosit[i][j], yBallPosit[i][j], zBallPosit[i][j]);
        vertex(xBallPosit[i+1][j], yBallPosit[i+1][j], zBallPosit[i+1][j]);
        vertex(xBallPosit[i+1][j+1], yBallPosit[i+1][j+1], zBallPosit[i+1][j+1]);
        vertex(xBallPosit[i][j+1], yBallPosit[i][j+1], zBallPosit[i][j+1]); 
        endShape(CLOSE);
        popMatrix();
      }
    }
  }
 // println(camera.position);
    
    if(mousePressed){ 
         pushMatrix();
         fill(255, 255, 255, random(0, 250));
         translate(sphereX, sphereY, sphereZ) ;
         sphere(sphereRadius);
         popMatrix();
   }
}

void collisionDetect(){

 for(int i = 0; i < numNodesY; i++){
   for(int j = 0; j < numNodesX; j++){
     
     float dist = dist(xBallPosit[i][j], yBallPosit[i][j],  sphereX, sphereY);
        if(dist < sphereRadius + 1){
         float xNorm = -1 * (sphereX - xBallPosit[i][j]);
         float yNorm = -1 * (sphereY - yBallPosit[i][j]);
         
         float Length = sqrt(xNorm*xNorm + yNorm*yNorm);
         
          xNorm = xNorm/Length;
          yNorm = yNorm/Length;
          
          float xprod = xNorm * xVel[i][j];
          float yprod = yNorm * yVel[i][j];
          
          float dotprod = xprod + yprod;
          
          float xbounce = dotprod * xNorm;
          float ybounce = dotprod * yNorm;
          
          xVel[i][j] -= 1.5* xbounce;
          yVel[i][j] -= 1.5* ybounce;
          
         float summ  = .1 + sphereRadius - dist; 
         
         xBallPosit[i][j] += summ * xNorm;
         yBallPosit[i][j] += summ * yNorm;
              
       }
     } 
   }
}
 
 
 // Created for CSCI 5611 by Liam Tyler and Stephen Guy

class Camera
{
  Camera()
  {
    position      = new PVector (233, 55, 1106); //( 260, -10, 983 ); // initial position
    theta         = 0; // rotation around Y axis. Starts with forward direction as ( 0, 0, -1 )
    phi           = 0; // rotation around X axis. Starts with up direction as ( 0, 1, 0 )
    moveSpeed     = 50;
    turnSpeed     = 1.57; // radians/sec
    
    // dont need to change these
    negativeMovement = new PVector( 0, 0, 0 );
    positiveMovement = new PVector( 0, 0, 0 );
    negativeTurn     = new PVector( 0, 0 ); // .x for theta, .y for phi
    positiveTurn     = new PVector( 0, 0 );
    fovy             = PI / 4;
    aspectRatio      = width / (float) height;
    nearPlane        = 0.1;
    farPlane         = 10000;
  }
  
  void Update( float dt )
  {
    theta += turnSpeed * (negativeTurn.x + positiveTurn.x) * dt;
    
    // cap the rotation about the X axis to be less than 90 degrees to avoid gimble lock
    float maxAngleInRadians = 85 * PI / 180;
    phi = min( maxAngleInRadians, max( -maxAngleInRadians, phi + turnSpeed * ( negativeTurn.y + positiveTurn.y ) * dt ) );
    
    // re-orienting the angles to match the wikipedia formulas: https://en.wikipedia.org/wiki/Spherical_coordinate_system
    // except that their theta and phi are named opposite
    float t = theta + PI / 2;
    float p = phi + PI / 2;
    PVector forwardDir = new PVector( sin( p ) * cos( t ),   cos( p ),   -sin( p ) * sin ( t ) );
    PVector upDir      = new PVector( sin( phi ) * cos( t ), cos( phi ), -sin( t ) * sin( phi ) );
    PVector rightDir   = new PVector( cos( theta ), 0, -sin( theta ) );
    PVector velocity   = new PVector( negativeMovement.x + positiveMovement.x, negativeMovement.y + positiveMovement.y, negativeMovement.z + positiveMovement.z );
    position.add( PVector.mult( forwardDir, moveSpeed * velocity.z * dt ) );
    position.add( PVector.mult( upDir,      moveSpeed * velocity.y * dt ) );
    position.add( PVector.mult( rightDir,   moveSpeed * velocity.x * dt ) );
    
    aspectRatio = width / (float) height;
    perspective( fovy, aspectRatio, nearPlane, farPlane );
    camera( position.x, position.y, position.z,
            position.x + forwardDir.x, position.y + forwardDir.y, position.z + forwardDir.z,
            upDir.x, upDir.y, upDir.z );
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyPressed()
  {
    if ( key == 'w' ) positiveMovement.z = 1;
    if ( key == 's' ) negativeMovement.z = -1;
    if ( key == 'a' ) negativeMovement.x = -1;
    if ( key == 'd' ) positiveMovement.x = 1;
    if ( key == 'q' ) positiveMovement.y = 1;
    if ( key == 'e' ) negativeMovement.y = -1;
    
    if ( keyCode == LEFT )  negativeTurn.x = 1;
    if ( keyCode == RIGHT ) positiveTurn.x = -1;
    if ( keyCode == UP )    positiveTurn.y = 1;
    if ( keyCode == DOWN )  negativeTurn.y = -1;
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyReleased()
  {
    if ( key == 'w' ) positiveMovement.z = 0;
    if ( key == 'q' ) positiveMovement.y = 0;
    if ( key == 'd' ) positiveMovement.x = 0;
    if ( key == 'a' ) negativeMovement.x = 0;
    if ( key == 's' ) negativeMovement.z = 0;
    if ( key == 'e' ) negativeMovement.y = 0;
    
    if ( keyCode == LEFT  ) negativeTurn.x = 0;
    if ( keyCode == RIGHT ) positiveTurn.x = 0;
    if ( keyCode == UP    ) positiveTurn.y = 0;
    if ( keyCode == DOWN  ) negativeTurn.y = 0;
  }
  
  // only necessary to change if you want different start position, orientation, or speeds
  PVector position;
  float theta;
  float phi;
  float moveSpeed;
  float turnSpeed;
  
  // probably don't need / want to change any of the below variables
  float fovy;
  float aspectRatio;
  float nearPlane;
  float farPlane;  
  PVector negativeMovement;
  PVector positiveMovement;
  PVector negativeTurn;
  PVector positiveTurn;
};




//// ----------- Example using Camera class -------------------- //
//Camera camera;

//void setup()
//{
//  size( 600, 600, P3D );
//  camera = new Camera();
//}

//void keyPressed()
//{
//  camera.HandleKeyPressed();
//}

//void keyReleased()
//{
//  camera.HandleKeyReleased();
//}

//void draw() {
//  background(255);
//  noLights();

//  camera.Update( 1.0/frameRate );
  
//  // draw six cubes surrounding the origin (front, back, left, right, top, bottom)
//  fill( 0, 0, 255 );
//  pushMatrix();
//  translate( 0, 0, -50 );
//  box( 20 );
//  popMatrix();
  
//  pushMatrix();
//  translate( 0, 0, 50 );
//  box( 20 );
//  popMatrix();
  
//  fill( 255, 0, 0 );
//  pushMatrix();
//  translate( -50, 0, 0 );
//  box( 20 );
//  popMatrix();
  
//  pushMatrix();
//  translate( 50, 0, 0 );
//  box( 20 );
//  popMatrix();
  
//  fill( 0, 255, 0 );
//  pushMatrix();
//  translate( 0, 50, 0 );
//  box( 20 );
//  popMatrix();
  
//  pushMatrix();
//  translate( 0, -50, 0 );
//  box( 20 );
//  popMatrix();
//}
