// Global named objects
int gMaxNumNamedPrimitives = 10;

int gNumNamedPrimitives = 0;
Primitive[] gNamedPrimitives = new Primitive[gMaxNumNamedPrimitives];
String[] gNamedPrimitiveNames = new String[gMaxNumNamedPrimitives];

 /**
  * @class Environment
  */
  class Environment {
    
    public int sMaxNumLights = 10;
    public int sMaxNumPrimitives = 80000;
    public int mNumLights;
    public int mNumPrimitives;
    
    float[] mBgColor = new float[3];
    int[] mBgColorInt = new int[3];
 
    Light[] mLights = new Light[sMaxNumLights];
    Primitive[] mPrimitives = new Primitive[sMaxNumPrimitives];

                 
    /** Constructor */
    Environment() {
      resetEnvironment();
      
      for( int i = 0; i < sMaxNumLights; ++i ) {
        mLights[i] = new Light();
      }

      for( int i = 0; i < sMaxNumPrimitives; ++i ) {
        mPrimitives[i] = new Primitive();
      }
      
    }
    
    /** @function resetEnvironment */
    void resetEnvironment() {
      mNumLights = 0;
      mNumPrimitives = 0;
      setBgColor(0,0,0);
      
      gNumNamedPrimitives = 0;
    }
    
    /**
     * @function addLight
     * @brief Add light counter and set xyz and rgb for added light
     */
    void addLight( float _x, float _y, float _z, float _r, float _g, float _b ) {
      mLights[mNumLights].setPos( _x, _y, _z );
      mLights[mNumLights].setRGB( _r, _g, _b );
      mNumLights++;
    }

    /**
     * @function printInfo 
     */       
    void printInfo() {
    
      print("** Background Color: " + mBgColor[0] + ", " + mBgColor[1] + ", " + mBgColor[2] + "\n");
      for( int i = 0; i < mNumLights; ++i ) {
        print("** Light ["+i+"]: \n");
        mLights[i].printInfo();
      }
      for( int i = 0; i < mNumPrimitives; ++i ) {
        print("** Primitive ["+i+"]: \n");
        mPrimitives[i].printInfo();
      }      
      
            for( int i = 0; i < gNumNamedPrimitives; ++i ) {
        print("** Named Primitive ["+i+"]: \n");
        gNamedPrimitives[i].printInfo();
      } 
      
    }   
       
    /**
     * @function addPrimitive
     */ 
    void addPrimitive( Primitive _primitive ) {
      
      if( _primitive.getType() == sSphereType ) {
        mPrimitives[mNumPrimitives] = new Sphere();
        ((Sphere)mPrimitives[mNumPrimitives]).copyData( (Sphere)_primitive );        
      } 
      else if( _primitive.getType() == sTriangleType ) {
        mPrimitives[mNumPrimitives] = new Triangle();
        ((Triangle)mPrimitives[mNumPrimitives]).copyData( (Triangle)_primitive );        
      } 
      else if( _primitive.getType() == sInstanceType ) {
        mPrimitives[mNumPrimitives] = new Instance();
        ((Instance)mPrimitives[mNumPrimitives]).copyData( (Instance)_primitive );        
      } 
      else if( _primitive.getType() == sBoxType ) {
        mPrimitives[mNumPrimitives] = new Box();
        ((Box)mPrimitives[mNumPrimitives]).copyData( (Box)_primitive );        
      } 
      else if( _primitive.getType() == sListType ) {
        mPrimitives[mNumPrimitives] = new List();
        ((List)mPrimitives[mNumPrimitives]).copyData( (List)_primitive );  
        ((List)mPrimitives[mNumPrimitives]).setBoundingBox(); 
      }


      mNumPrimitives++;
    }                

    
    /**
     * @function setBgColor 
     */
    void setBgColor( float _r, float _g, float _b ) {
      mBgColor[0] = _r; mBgColorInt[0] = (int)(_r*255.0);
      mBgColor[1] = _g; mBgColorInt[1] = (int)(_g*255.0);
      mBgColor[2] = _b; mBgColorInt[2] = (int)(_b*255.0);
    }
    
    /** Getters */
    int getNumPrimitives() { return mNumPrimitives; }

    /////////////// GLOBAL STUFF ////////////////////////////////

    /**< addNamedPrimitive */
    void addNamedPrimitive( Primitive _primitive, String _name ) {
      
      if( _primitive.getType() == sSphereType ) {
        gNamedPrimitives[gNumNamedPrimitives] = new Sphere();
        ((Sphere)gNamedPrimitives[gNumNamedPrimitives]).copyData( (Sphere)_primitive );        
      } 
      else if( _primitive.getType() == sTriangleType ) {
        gNamedPrimitives[gNumNamedPrimitives] = new Triangle();
        ((Triangle)gNamedPrimitives[gNumNamedPrimitives]).copyData( (Triangle)_primitive );        
      } 
      
      gNamedPrimitiveNames[gNumNamedPrimitives] = _name;
      gNumNamedPrimitives++;
      print("Num named primitives: "+gNumNamedPrimitives + "\n");
    }   

    /** getInstanceInd */
    int getInstanceInd( String name ) {
    
      for( int i = 0; i < gNumNamedPrimitives; ++i ) {
        if( gNamedPrimitiveNames[i].equals(name) ) { return i; }
      }
      
      return -1;   
    }
    
  };


