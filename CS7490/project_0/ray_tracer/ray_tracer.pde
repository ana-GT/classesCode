///////////////////////////////////////////////////////////////////////
//
//  Ray Tracing Shell
// @author A. Huaman based on template code of Prof. Greg Turk
///////////////////////////////////////////////////////////////////////

int screen_width = 300;
int screen_height = 300;

int sTriangleType = 0;
int sSphereType = 1;

Environment gEnv = new Environment();
RayTracer gRayTracer = new RayTracer();

// the current active file name
String gCurrentFile = new String("rect_test.cli");   


/**
 * @function setup
 * @brief Some initializations for the scene.
 */
void setup() {
  size (screen_width, screen_height);  
  noStroke();
  colorMode (RGB, 255);
  background (0, 0, 0);
  interpreter();
}

/**
 * @function keyPressed
 * @brief Press key 1 to 9 and 0 to run different test cases.
 */
void keyPressed() {
  switch(key) {
    case '1':  gCurrentFile = new String("t0.cli"); interpreter(); break;
    case '2':  gCurrentFile = new String("t1.cli"); interpreter(); break;
    case '3':  gCurrentFile = new String("c0.cli"); interpreter(); break;
    case '4':  gCurrentFile = new String("c1.cli"); interpreter(); break;
    case '5':  gCurrentFile = new String("c2.cli"); interpreter(); break;
    case '6':  gCurrentFile = new String("c3.cli"); interpreter(); break;
  }
}

/** 
 * @function interpreter
 * @brief  Parser core. It parses the CLI file and processes it based on each 
 *  token.
 */
void interpreter() {
  
  boolean readingPolygon;
  Triangle triangle = new Triangle();
  int polygonIndex;
  float  cdr, cdg, cdb, car, cag, cab;
  
  // Initialize values
  readingPolygon = false;
  polygonIndex = 0;
  cdr = 1.0; cdg = 0.0; cdb = 0.0;
  car = 0.1; cag = 0.9; cab = 0.0;
  
  // Reset environment
  gEnv.resetEnvironment();
  
  // Set ray tracer with global vars
  gRayTracer.setPixelDims( screen_width, screen_height );
  
  String str[] = loadStrings(gCurrentFile);
  
  /** If no file is loaded, display error message and exit */
  if (str == null) {
      println("Error! Failed to read the file.");
  }
  
  /** Go through each line and parse them */
  for (int i=0; i<str.length; i++) {
    
    // Get a line and parse tokens.
    String[] token = splitTokens(str[i], " ");
    // Skip blank line. 
    if (token.length == 0) {
      continue; 
    }
    
    /** Field of view angle */
    if (token[0].equals("fov")) {
      gRayTracer.setFov( Float.parseFloat( token[1] ) );
    }
    
    /** Set background color */
    else if (token[0].equals("background")) {
      gEnv.setBgColor( Float.parseFloat(token[1]), 
                       Float.parseFloat(token[2]), 
                       Float.parseFloat(token[3]) );
    }
    
    /** Add a light source to the environment */
    else if (token[0].equals("light")) {
      float x, y, z, r, g, b;
      x = Float.parseFloat(token[1]);
      y = Float.parseFloat(token[2]);
      z = Float.parseFloat(token[3]);
      r = Float.parseFloat(token[4]);
      g = Float.parseFloat(token[5]);
      b = Float.parseFloat(token[6]);
      gEnv.addLight( x, y, z, r, g, b ); 
    }
    
    /** Set diffuse and ambience coefficients */
    else if (token[0].equals("diffuse")) {
      cdr = Float.parseFloat( token[1] );
      cdg = Float.parseFloat( token[2] );
      cdb = Float.parseFloat( token[3] );
      car = Float.parseFloat( token[4] );
      cag = Float.parseFloat( token[5] );
      cab = Float.parseFloat( token[6] );
    }    
    
    /** Start reading polygon */
    else if (token[0].equals("begin")) {
      readingPolygon = true;
      polygonIndex = 0;
      triangle = new Triangle();
    }
    
    /** Finish reading polygon */
    else if (token[0].equals("end")) {
      triangle.setDiffuseCoeff( cdr, cdg, cdb );
      triangle.setAmbienceCoeff( car, cag, cab );
      gEnv.addPrimitive( triangle );
      readingPolygon = false;
    }
    
    /** Read a vertex of the polygon */
    else if (token[0].equals("vertex")) {
      float vx, vy, vz;
      vx = Float.parseFloat(token[1]);
      vy = Float.parseFloat(token[2]);
      vz = Float.parseFloat(token[3]);    
        
      triangle.addVertex( polygonIndex, vx, vy, vz );
      polygonIndex++;
    }
    
    /** Read sphere */
    else if (token[0].equals("sphere")) {
      float x, y, z, r;
      r = Float.parseFloat( token[1] );
      x = Float.parseFloat( token[2] );
      y = Float.parseFloat( token[3] );
      z = Float.parseFloat( token[4] );
      Sphere sphere = new Sphere();
      sphere.set( r, x, y, z );
      sphere.setDiffuseCoeff( cdr, cdg, cdb );
      sphere.setAmbienceCoeff( car, cag, cab );
      
      gEnv.addPrimitive( sphere );
    }
    
    /** Stack operations */
    else if (token[0].equals("push")) {
 
    }    
    
   /** Stack operations */
    else if (token[0].equals("pop")) {
 
    }        
    
       /** Translate */
    else if (token[0].equals("translate")) {
 
    }    
    
      /** Translate */
    else if (token[0].equals("scale")) {
 
    }    
    
     /** Rotate */
    else if (token[0].equals("rotate")) {
 
    }    
    
    /** Dummy parse */
    else if (token[0].equals("color")) {
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      fill(r, g, b);
    }
    
    /** Dummy parse */
    else if (token[0].equals("rect")) {
      float x0 = float(token[1]);
      float y0 = float(token[2]);
      float x1 = float(token[3]);
      float y1 = float(token[4]);
      rect(x0, screen_height-y1, x1-x0, y1-y0);
    }
    
    /** Save the current image to a .png file */
    else if (token[0].equals("write")) {
      gRayTracer.init();
      gRayTracer.render();
      save(token[1]);  
    }
  } // End for
  
  // Debug
  print("**** Print Info for current file: " + gCurrentFile + " **** \n");
  print(" ENVIRONMENT INFO: \n");
  gEnv.printInfo();
  print("RAY TRACER INFO: \n");
  gRayTracer.printInfo();
}

//  Draw frames.  Should be left empty.
void draw() {
}


 

