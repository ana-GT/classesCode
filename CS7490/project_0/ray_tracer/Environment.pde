 /**
  * @class Environment
  */
  class Environment {
    
    public int sMaxNumLights = 10;
    public int sMaxNumPrimitives = 255;
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
    
  };

/**********************
 * @class Primitive
 ***********************/
class Primitive {
  public int mType;  
  
  public float[] mDiff = new float[3];
  public float[] mAmb = new float[3];

  Primitive() { mType = sSphereType; }
  Primitive( int _type ) { mType = _type; }

  /**Return type */
  int getType() { return mType; }
  
  void copyData( Primitive _p ) {};

  /** Set diffuse coefficient */
  void setDiffuseCoeff( float _cdr, float _cdg, float _cdb ) {
    mDiff[0] = _cdr;
    mDiff[1] = _cdg;
    mDiff[2] = _cdb;
  }  
  
  /** Set Ambience coeff */
  void setAmbienceCoeff( float _car, float _cag, float _cab ) {
    mAmb[0] = _car;
    mAmb[1] = _cag;
    mAmb[2] = _cab;
  }
  
  /** printInfo() */
  void printInfo() { println("Primitive info default - YOU MUST INSTANCE THIS!"); }
}

/****************************
 * @class Triangle
 ****************************/
class Triangle extends Primitive {

  public pt[] mV = new pt[3];
  
  /** Constructor */
  Triangle() {
    super( sTriangleType );    
    for( int i = 0; i < 3; ++i ) {
      mV[i] = new pt();
    }
  }
  
  /** @function addVertex */
  void addVertex( int _ind, float _vx, float _vy, float _vz ) {

    if( _ind >= 3 || _ind < 0 ) {
      println("Index out of bounds. Should be between 0 and 2 for a triangle");
      return;
    }
    
    mV[_ind].set(_vx, _vy, _vz );
  }
  
  /** @function copyData */
  void copyData( Triangle _triangle ) {
    for( int i = 0; i < 3; ++i ) {
      mV[i] = _triangle.mV[i];
    }
    setDiffuseCoeff( _triangle.mDiff[0], _triangle.mDiff[1], _triangle.mDiff[2] );
    setAmbienceCoeff( _triangle.mAmb[0], _triangle.mAmb[1], _triangle.mAmb[2] );
  }
  
  /**
   * @function printInfo
   */
  void printInfo() {
    print("\t Primitive: Triangle \n");
    print( "\t V1: "+ mV[0].x + "," + mV[0].y + ", " + mV[0].z + "\n" );
    print( "\t V2: "+ mV[1].x + "," + mV[1].y + ", " + mV[1].z + "\n" );
    print( "\t V3: "+ mV[2].x + "," + mV[2].y + ", " + mV[2].z + "\n" );
    
    print( "\t Diffuse Coeff: " + mDiff[0] +", "+mDiff[1]+", "+mDiff[2] + "\n");
    print( "\t Ambience Coeff: " + mAmb[0] +", "+mAmb[1]+", "+mAmb[2] + "\n");
  }
  
};



/**************************
 * @class Sphere
 **************************/
class Sphere extends Primitive {
 
  public pt mC; /** Center */
  public float mR;  /** Radius */
  
  /** Constructor */
  Sphere() {
    super( sSphereType );
    mC = new pt();
    mR = 1;
  }

  /** Set values */  
  void set( float _r, float _x, float _y, float _z ) {
    mC.set( _x, _y, _z );
    mR = _r;
  }
  
  /** copyData */
  void copyData( Sphere _sphere ) {
    mC = _sphere.mC;
    mR = _sphere.mR;
    setDiffuseCoeff( _sphere.mDiff[0], _sphere.mDiff[1], _sphere.mDiff[2] );
    setAmbienceCoeff( _sphere.mAmb[0], _sphere.mAmb[1], _sphere.mAmb[2] );
  }
  
  /**
   * @function printInfo
   */
  void printInfo() {
    print("\t Primitive: Sphere \n");
    print( "\t C: " + mC.x + "," + mC.y + ", " + mC.z + "\n" );
    print( "\t R: " + mR + "\n" );
    
    print( "\t Diffuse Coeff: " + mDiff[0] +", "+mDiff[1]+", "+mDiff[2] + "\n");
    print( "\t Ambience Coeff: " + mAmb[0] +", "+mAmb[1]+", "+mAmb[2] + "\n");
  }
  
};

/******************************
 * @class Light
 ******************************/
class Light {
  public pt mPos = new pt();
  public float[] mRGB = new float[3];
  
  /**Constructor */
  Light() {
    
  }
  
  /** Set position */
  void setPos( float _x, float _y, float _z ) {
    mPos.set(_x, _y, _z);
  }
  
  /** Set color */
  void setRGB( float _r, float _g, float _b ) {
    mRGB[0] = _r; mRGB[1] = _g; mRGB[2] = _b;
  }

  /**
   * @function printInfo
   */
  void printInfo() {
    print( "\t Pos: "+ mPos.x + "," + mPos.y + ", " + mPos.z + "\n" );
    print( "\t Color: "+ mRGB[0] + "," + mRGB[1] + ", " + mRGB[2] + "\n" );    
  }

}


  
 
