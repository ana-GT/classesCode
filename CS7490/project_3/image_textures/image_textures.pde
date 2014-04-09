///////////////////////////////////////////////////////////////////////
//
//  Image textures
// @author A. Huaman based on template code of Prof. Greg Turk
///////////////////////////////////////////////////////////////////////

int screen_width = 600;
int screen_height = 600;

int sDefaultType = 0;
int sTriangleType = 1;
int sSphereType = 2;
int sInstanceType = 3;

int sPointLight = 0;
int sDiskLight = 1;

int sSurfaceType = 0;
int sDiffuseType = 1;
int sShinyType = 2;

int MAX_DEPTH = 4;


Environment gEnv = new Environment();
RayTracer gRayTracer = new RayTracer();
int timer;
 
 // Interpreter variables ------------------
   boolean readingPolygon;
  Triangle triangle = new Triangle();
  int polygonIndex;
  int coord_u, coord_v;
  String imageTexture;
  float  cdr, cdg, cdb, car, cag, cab;
  float csr, csg, csb, specPower, Kref;
  naiveStack mStack;
  PMatrix3D mMat;
  Surface surface;
  float cu[] = new float[3]; 
  float cv[] = new float[3]; 
  int uvi;
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
  interpreter("data/rect_test.cli");
}

/**
 * @function keyPressed
 * @brief Press key 1 to 8 and 0 to run different test cases.
 */
void keyPressed() {
  initInterpreter();
  switch(key) {
    case '1':  interpreter("data/t01.cli"); break;
    case '2':  interpreter("data/t02.cli"); break;
    case '3':  interpreter("data/t03.cli"); break;
    case '4':  interpreter("data/t04.cli"); break;
    case '5':  interpreter("data/t05.cli"); break;
    case '6':  interpreter("data/t06.cli"); break;
    case '7':  interpreter("data/t07.cli"); break;
    case '8':  interpreter("data/t08.cli"); break;
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
  Primitive prim = new Primitive();
  
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
      surface = new Diffuse();
      surface.setDiffCoeff( cdr, cdg, cdb );
      surface.setAmbCoeff( car, cag, cab );
    }    
    
    else if (token[0].equals("shiny") ) {
      cdr = Float.parseFloat( token[1] );
      cdg = Float.parseFloat( token[2] );
      cdb = Float.parseFloat( token[3] );
      car = Float.parseFloat( token[4] );
      cag = Float.parseFloat( token[5] );
      cab = Float.parseFloat( token[6] );
      csr = Float.parseFloat( token[7] );
      csg = Float.parseFloat( token[8] );
      csb = Float.parseFloat( token[9] );
      specPower = Float.parseFloat( token[10] );
      Kref = Float.parseFloat( token[11] ); 
 
      surface = new Shiny();
      surface.setDiffCoeff( cdr, cdg, cdb );
      surface.setAmbCoeff( car, cag, cab );
      ((Shiny)surface).setSpecCoeff( csr, csg, csb );
      ((Shiny)surface).setSpecPower( specPower );
      ((Shiny)surface).setKref( Kref );     
      print("Spec power: " + specPower + " Kref: " + Kref + "\n");
    }
    
    /** Image texture */
    else if( token[0].equals("image_texture") ) {
      imageTexture = token[1];
      surface.setImageTexture_filename( imageTexture );
    }

    else if( token[0].equals( "texture_coord" ) ) {
      coord_u = Integer.parseInt( token[1] );
      coord_v = Integer.parseInt( token[2] );
    }

    /**< Named_object */
    else if( token[0].equals("named_object") ) {
      String name = token[1];
      gEnv.addNamedPrimitive( prim, name );
    }
    
    /**< Instance */
    else if( token[0].equals("instance") ) {
      int ind = gEnv.getInstanceInd( token[1] );
      Instance inst = new Instance( ind, mMat );
      gEnv.addPrimitive( inst );
    }
    
    /** Start reading polygon */
    else if (token[0].equals("begin")) {
      readingPolygon = true;
      polygonIndex = 0;
      triangle = new Triangle();
      uvi = 0; coord_u = -1; coord_v = -1;
      cu = new float[3];
      cv = new float[3];
    }
    
    /** Finish reading polygon */
    else if (token[0].equals("end")) {
      triangle.setSurface( surface );      
      // If textures were stored
      if( uvi == 3 ) {
        triangle.setVertexColor( cu, cv );        
      }
      triangle.printInfo();
      
      gEnv.addPrimitive( triangle );      
      readingPolygon = false;
    }
    
    /** Read a vertex of the polygon */
    else if (token[0].equals("vertex")) {
      float vx, vy, vz;
      vx = Float.parseFloat(token[1]);
      vy = Float.parseFloat(token[2]);
      vz = Float.parseFloat(token[3]);    
        
      if( coord_u != -1 && coord_v != -1 ) {
        cu[uvi] = coord_u; cv[uvi] = coord_v;
        uvi++;
      }  
        
        
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
      sphere.setSurface( surface );
      
      prim = sphere;
      if( filename != "data/t04.cli" ) {
        gEnv.addPrimitive( sphere );
      }
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
    
    /** Rays per pixel*/
    else if ( token[0].equals("rays_per_pixel") ) {
      int num = int( token[1] );
      gRayTracer.setRaysPerPixel( num );
    }
    
    /** Disk light */
    else if( token[0].equals("disk_light") ) {
      float center_x = float( token[1] ); 
      float center_y = float( token[2] ); 
      float center_z = float( token[3] ); 

      float radius = float( token[4] ); 

      float normal_x = float( token[5] ); 
      float normal_y = float( token[6] ); 
      float normal_z = float( token[7] ); 

      float r = float( token[8] );
      float g = float( token[9] );
      float b = float( token[10] );
      
      DiskLight dl = new DiskLight();
      dl.setPos( center_x, center_y, center_z );
      dl.setRGB( r, g, b );
      dl.setNormal( normal_x, normal_y, normal_z );
      dl.setRadius( radius );
      
      gEnv.addLight( dl );
    }
    

    
    /**< Depth of field effect */
    else if( token[0].equals("lens") ) {
      float radius = float( token[1] );
      float focal_distance = float( token[2] );
      gRayTracer.setLens( radius, focal_distance );
    }
    
    /** Save the current image to a .png file */
    else if (token[0].equals("write")) {
      if( gEnv.mNumPrimitives > 0 ) {
        gRayTracer.init();
        gRayTracer.render();
        print("Finished rendering " + token[1] + "\n");
      }
      save(token[1]);  
    }
    
    
  } // End for
  
  
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
