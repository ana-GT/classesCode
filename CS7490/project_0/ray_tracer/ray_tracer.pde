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
 
 
 // Interpreter variables ------------------
   boolean readingPolygon;
  Triangle triangle = new Triangle();
  int polygonIndex;
  float  cdr, cdg, cdb, car, cag, cab;
  naiveStack mStack;
  PMatrix3D mMat;
  // -----------------------------------------


/**
 * @function setup
 * @brief Some initializations for the scene.
 */
void setup() {
  size (screen_width, screen_height);  
  noStroke();
  colorMode (RGB, 255);
  background (0, 0, 0);
  interpreter("rect_test.cli");
}

/**
 * @function keyPressed
 * @brief Press key 1 to 9 and 0 to run different test cases.
 */
void keyPressed() {
  initInterpreter();
  switch(key) {
    case '1':  interpreter("bunny.cli"); break;
    case '2':  interpreter("t02.cli"); break;
    case '3':  interpreter("t03.cli"); break;
    case '4':  interpreter("t04.cli"); break;
    case '5':  interpreter("t05.cli"); break;
    case '6':  interpreter("t06.cli"); break;
    case '7':  interpreter("t07.cli"); break;
    case '8':  interpreter("t08.cli"); break;
    case '9':  interpreter("t09.cli"); break;
    case '0':  interpreter("t10.cli"); break;
    case 'q':  exit(); break;
  }
}



/** 
 * @function interpreter
 * @brief  Parser core. It parses the CLI file and processes it based on each 
 *  token.
 */
void interpreter(String filename) {
  
  String str[] = loadStrings(filename);
  
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
    else if (token[0].equals("point_light")) {
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
        
      // Apply matrix in stack
      float[] vm = new float[3];
      float[] v = new float[3];
      v[0] = vx; v[1] = vy; v[2] = vz;
      mMat.mult( v, vm  );        
        
      triangle.addVertex( polygonIndex, vm[0], vm[1], vm[2] );
      polygonIndex++;
    }
    
    /** Read sphere */
    else if (token[0].equals("sphere")) {
      float x, y, z, r;
      r = Float.parseFloat( token[1] );
      x = Float.parseFloat( token[2] );
      y = Float.parseFloat( token[3] );
      z = Float.parseFloat( token[4] );
      
      // Apply matrix in stack
      float[] pm = new float[3];
      float[] p = new float[3];
      p[0] = x; p[1] = y; p[2] = z;
      mMat.mult( p, pm  );
      
      Sphere sphere = new Sphere();
      sphere.set( r, pm[0], pm[1], pm[2] );
      sphere.setDiffuseCoeff( cdr, cdg, cdb );
      sphere.setAmbienceCoeff( car, cag, cab );
      
      gEnv.addPrimitive( sphere );
    }
    
    /** Stack operations */
    else if (token[0].equals("push")) {
      mStack.push( mMat );
    }    
    
   /** Stack operations */
    else if (token[0].equals("pop")) {
      PMatrix3D mat = new PMatrix3D();
      mat = mStack.pop();
      mMat.set( mat );
    }        
    
       /** Translate */
    else if (token[0].equals("translate")) {
      float x, y, z;
      x = Float.parseFloat( token[1] );
      y = Float.parseFloat( token[2] );
      z = Float.parseFloat( token[3] );
      mMat.translate(x,y,z);
    }    
    
      /** Scale */
    else if (token[0].equals("scale")) {
      float x, y, z;
      x = Float.parseFloat( token[1] );
      y = Float.parseFloat( token[2] );
      z = Float.parseFloat( token[3] );      
      mMat.scale(x,y,z); 
    }    
    
     /** Rotate */
    else if (token[0].equals("rotate")) {
      float angle, x, y, z;
      angle = Float.parseFloat( token[1] );
      x = Float.parseFloat( token[2] );
      y = Float.parseFloat( token[3] );
      z = Float.parseFloat( token[4] );
      mMat.rotate( radians(angle), x, y, z );
    }    
    
   /** reads input from another file */
    else if (token[0].equals("read")) {
      interpreter(token[1]);
    }

    /** Dummy parse */
    else if (token[0].equals("color")) {
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      int ri, gi, bi;
      ri = (int)(255.0*r);
      gi = (int)(255.0*g);
      bi = (int)(255.0*b);      
      fill(ri, gi, bi);
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
      if( gEnv.mNumPrimitives > 0 ) {
        gRayTracer.init();
        gRayTracer.render();
      }
      save(token[1]);  
    }
  } // End for
  
  // Debug
  //print("**** Print Info for current file: " + gCurrentFile + " **** \n");
  //print(" ENVIRONMENT INFO: \n");
  //gEnv.printInfo();
  //print("RAY TRACER INFO: \n");
  //gRayTracer.printInfo();
}

//  Draw frames.  Should be left empty.
void draw() {
}

// when mouse is pressed, print the cursor location
void mousePressed() {
  println ("mouse: " + mouseX + " " + mouseY);
}

/**< Reset interpreter variables when a new main file (not included) is loaded */ 
void initInterpreter() { 
  
  // Set matrix to store current position - Start with identity
  mStack = new naiveStack();
  mMat = new PMatrix3D();
  mMat.reset();
  
  // Initialize values
  readingPolygon = false;
  polygonIndex = 0;
  cdr = 1.0; cdg = 0.0; cdb = 0.0;
  car = 0.1; cag = 0.9; cab = 0.0;
  
  // Reset environment
  gEnv.resetEnvironment();
  
  // Set ray tracer with global vars
  gRayTracer.setPixelDims( screen_width, screen_height );
}
