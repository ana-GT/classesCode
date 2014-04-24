/**********************
 * @class Surface
 **********************/
 class Surface {
 
   public int mType;
   public float[] mDiff = new float[3];
   public float[] mAmb = new float[3];   
   public ImageTexture mTexture;
   public boolean mIsTextured;
   public int mNoise;
   public int mMaterialType; 
   
   Surface() { mType = sSurfaceType; mIsTextured = false; mNoise = 0; mMaterialType = sNoType; }
   Surface( int _type ) { mType = _type; mIsTextured = false; }
   
   int getType() { return mType; }
   
   void setDiffCoeff( float _cdr, float _cdg, float _cdb ) {
     mDiff[0] = _cdr; 
     mDiff[1] = _cdg; 
     mDiff[2] = _cdb; 
   }
   
   void setAmbCoeff( float _car, float _cag, float _cab ) {
     mAmb[0] = _car; 
     mAmb[1] = _cag; 
     mAmb[2] = _cab; 
   }
   
   /** Set Image texture */
   void setImageTexture_filename( String _filename ) {
     mTexture = new ImageTexture( _filename );
     mIsTextured = true;
   }
   
   /** Set Noise */
   void setNoise( int _noise ) { mNoise = _noise; }
   
   /** Material type */
   void setMaterialType( int _materialType ) { mMaterialType = _materialType; }
   
   void printInfo() {
     print( "\t Diffuse Coeff: " + mDiff[0] +", "+mDiff[1]+", "+mDiff[2] + "\n");
     print( "\t Ambience Coeff: " + mAmb[0] +", "+mAmb[1]+", "+mAmb[2] + "\n");
   }
   
 }
 
 /**
  * @class Diffuse
  * @brief Diffuse surface type
  */
 class Diffuse extends Surface {

    Diffuse() {
      super( sDiffuseType );
    }
   
   void printInfo() {
     print( "\t Diffuse Coeff: " + mDiff[0] +", "+mDiff[1]+", "+mDiff[2] + "\n");
     print( "\t Ambience Coeff: " + mAmb[0] +", "+mAmb[1]+", "+mAmb[2] + "\n");
   }
    
 }
 
 /**
  * @class Shiny
  * @brief Shiny surface type
  */
 class Shiny extends Surface {
 
   public float[] mSpec = new float[3];
   public float mSpecPower;
   public float mKref;
   
   public boolean isReflective() {
     if( mKref != 0 ) { return true; }
     else { return false; }
   }
   
   Shiny() {
     super( sShinyType );
     mKref = 0;
     mSpecPower = 1;
   }
   
   void setSpecCoeff( float _csr, float _csg, float _csb ) {
     mSpec[0] = _csr; 
     mSpec[1] = _csg; 
     mSpec[2] = _csb; 
   }
   
   void setSpecPower( float _alpha ) {
     mSpecPower = _alpha;
   }
   
   void setKref( float _Kref ) {
     mKref = _Kref;
   }
   
   void printInfo() {
     print( "\t Diffuse Coeff: " + mDiff[0] +", "+mDiff[1]+", "+mDiff[2] + "\n");
     print( "\t Ambience Coeff: " + mAmb[0] +", "+mAmb[1]+", "+mAmb[2] + "\n");
     print( "\t Spec Coeff: " + mSpec[0] +", "+mSpec[1]+", "+mSpec[2] + "\n");     
     print( "\t Spec power: " + mSpecPower + " Kref: " + mKref + "\n" );
   }
   
 }
 
/**********************
 * @class Primitive
 ***********************/
class Primitive {
  public int mType;  
  
  public Surface mSurface;

  Primitive() { mType = sDefaultType; }
  Primitive( int _type ) { mType = _type; }

  /**Return type */
  int getType() { return mType; }
  
  void copyData( Primitive _p ) {};

  Surface getSurface() { return mSurface; }
  
  boolean hit( ray _R, hitRecord _rec ) { print("I SHOULD NOT BE CALLED \n");return false; }

  /** Set diffuse coefficient */
  void setSurface( Surface _surface ) {

    if( _surface.getType() == sDiffuseType ) {
      mSurface = (Diffuse) _surface;
    } else if( _surface.getType() == sShinyType ) {
      mSurface = (Shiny) _surface;
    }
    
  }  

  /** get Diffuse color when using mipMap */
  float[] getDiff( pt _P, rayMipMap _R ) {

      // You are never supposed to call this from Primitive base class    
      return getDiff( _P );

  }

  
  /** get Diffuse color */
  float[] getDiff( pt _P ) {
    return mSurface.mDiff;
  }
  
  /** get Ambience color */
  float[] getAmb() {
    return mSurface.mAmb;
  }
  
  /** printInfo() */
  void printInfo() { println("Primitive info default - YOU MUST INSTANCE THIS!"); }
}

/****************************
 * @class Triangle
 ****************************/
class Triangle extends Primitive {

  public pt[] mV = new pt[3];
  public float[] mVu = new float[3];
  public float[] mVv = new float[3];  
  
  /** Constructor */
  Triangle() {
    super( sTriangleType );    
    for( int i = 0; i < 3; ++i ) {
      mV[i] = new pt();
    }
  }

  /** If triangle is textured */
  void setVertexColor( float[] _u, float[] _v ) {
    mVu = _u; mVv = _v;
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
    
    setSurface( _triangle.mSurface );
  }
  
  /** @function hit */
  // Adapted from http://geomalgorithms.com/a06-_intersect-2.html
  boolean hit( ray _R, hitRecord _rec ) {
  
       vec u = V( mV[0], mV[1] );
       vec v = V( mV[0], mV[2] );
       vec n =  N( u, v );
       if( n.x == 0 && n.y == 0 && n.z == 0 ) { return false; } // Degenerate triangle
       
       vec w0 = V( _R.P, mV[0] );
       float a = d( n, w0 );
       float b = d( n, _R.T );
       if( abs( b ) < 0.000001 ) {
         if( a == 0 ) { return false; } // Ray lies in plane of triangle
         else return false; // Ray disjoint from plane YAY
       }
       
       // Get intersect point of ray with triangle plane
       float r = a / b;  
       if( r < 0.0 ) { return false; }
       
       pt I = P( _R.P, r, _R.T );
       float uu, uv, vv, wu, wv, D; vec w;
       uu = d( u, u );
       uv = d( u, v );
       vv = d( v, v );
       w = V( mV[0], I );
       wu = d( w, u );
       wv = d( w, v );
       D = uv*uv - uu*vv;
       
       // Get and test parametric coords
       float s, t;
       s = (uv*wv - vv*wu ) / D;
       if( s < 0.0 || s > 1.0 ) { return false; } // I is outside T
       
       t = (uv*wu - uu*wv ) / D;
       if( t < 0.0 || (s+t) > 1.0 ) { return false; } // I is outside T
       
       float dist = r;

       // Store hit record
        _rec.dist = dist;
        _rec.point = I;
        _rec.normal = n;
       
       return true;
    
  }
  
  
    
  /** get Diffuse color */
  float[] getDiff( pt _P ) {

    if( mSurface.mIsTextured == true ) {
      
      float tuv[] = new float[2]; tuv = get_tuv( _P );
      PVector uvd = new PVector();
      uvd.x = tuv[0]; uvd.y = tuv[1]; uvd.z = 0;
      PVector c = mSurface.mTexture.color_value( uvd ); 
      
      float col[] = new float[3]; 
      col[0] = c.x / 255.0; col[1] = c.y / 255.0; col[2] = c.z / 255.0;
      return col;
    } else {
      return mSurface.mDiff;
    }
  }
  
  
    /** get Diffuse color when using mipMap */
  float[] getDiff( pt _P, rayMipMap _R ) {
    
    if(  mSurface.mIsTextured == true ) {

      // Check that all points are in the object
      if( _R.oUp.is_set() == false || _R.oRight.is_set() == false ){
        return getDiff( _P );
      }  
      // Check that both fall in the same object (supposedly this one)
      if( _R.oUp.objIndex != _R.oRight.objIndex ) {
        return getDiff( _P );
        
      }
      
      // Now we can proceed
      float tuv[] = new float[2]; tuv = get_tuv( _P );
      float tu = tuv[0]; float tv = tuv[1];
      
      // Get the other 2 coordinates
      float tuv1[] = new float[2]; tuv1 = get_tuv( _R.oUp.P );
      float tu1 = tuv1[0]; float tv1 = tuv1[1];

      float tuv2[] = new float[2]; tuv2 = get_tuv( _R.oRight.P );
      float tu2 = tuv2[0]; float tv2 = tuv2[1];

      // Get distance between points
      float dist1 = sqrt( (tu-tu1)*(tu-tu1) + (tv-tv1)*(tv-tv1) );
      float dist2 = sqrt( (tu-tu2)*(tu-tu2) + (tv-tv2)*(tv-tv2) );
      
      PVector uvd = new PVector();
      uvd.x = tu; uvd.y = tv;
      if( dist1 > dist2 ) { uvd.z = dist1; } else { uvd.z = dist2; }
      
      PVector c = mSurface.mTexture.color_value( uvd ); 
      float col[] = new float[3]; 
      col[0] = c.x / 255.0; col[1] = c.y / 255.0; col[2] = c.z / 255.0;
      return col;

    }  
      
    else {  
      return mSurface.mDiff;
    }
  }
 

  /** Get tuv : Coordinates of textures in [0 1] range */
  float[] get_tuv( pt _P ) {
  
    float tuv[] = new float[2];
    
    // Get the barycentric coordinates of this point
    float[] barCoord = getBarycentricCoordinates( mV[0], mV[1], mV[2], _P );
    tuv[0] = mVu[0]*barCoord[0] + mVu[1]*barCoord[1]  + mVu[2]*barCoord[2];
    tuv[1] = ( mVv[0]*barCoord[0] + mVv[1]*barCoord[1]  + mVv[2]*barCoord[2] );      
    
    return tuv;
  }
  
  
  /**
   * @function printInfo
   */
  void printInfo() {
    print("\t Primitive: Triangle \n");
    print( "\t V1: "+ mV[0].x + "," + mV[0].y + ", " + mV[0].z + "\n" );
    print( "\t V2: "+ mV[1].x + "," + mV[1].y + ", " + mV[1].z + "\n" );
    print( "\t V3: "+ mV[2].x + "," + mV[2].y + ", " + mV[2].z + "\n" );

    mSurface.printInfo();    
 
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
    mC.x = _sphere.mC.x; mC.y = _sphere.mC.y; mC.z = _sphere.mC.z;
    print("Center: " + mC.x + " " + mC.y + " " + mC.z + "\n");
    mR = _sphere.mR;
    setSurface( _sphere.mSurface );
  }
  
  
    /** @function hit */
  boolean hit( ray _R, hitRecord _rec ) {    
    float A = d( _R.T, _R.T );
    vec ec = V( this.mC, _R.P );
    float B = 2.0*d( _R.T, ec );
    float r = this.mR;
    float C = d( ec, ec ) - r*r;
       
    float D = sq(B) - 4*A*C;

    if( D < 0 ) { return false; } // No intersect
    else {
          float sqD = abs( sqrt(D));
         float t1, t2, dist;
         t1 = (-B + sqD) / (2.0*A);
         t2 = (-B - sqD) / (2.0*A);

         if( t1 < 0 && t2 < 0 ) { return false; }
         else if( t1 < 0 && t2 > 0 ) { dist = t2; }
         else if( t1 > 0 && t2 < 0 ) { dist = t1; }
         else {
           if( t1 < t2 ) { dist = t1; } else { dist = t2; }
         }

    _rec.dist = dist;
    _rec.point = P(_R.P, dist, _R.T);
    _rec.normal = V( this.mC, _rec.point );
                   
    return true;
   }
 }

  /** get Diffuse color */
  float[] getDiff( pt _P ) {

    if( mSurface.mIsTextured == true ) {
      
      float tuv[] = new float[2]; tuv = get_tuv( _P );
      PVector uvd = new PVector();
      uvd.x = tuv[0]; uvd.y = tuv[1]; uvd.z = 0;
      PVector c = mSurface.mTexture.color_value( uvd ); 
      
      float col[] = new float[3]; 
      col[0] = c.x / 255.0; col[1] = c.y / 255.0; col[2] = c.z / 255.0;
      return col;
    } else {
      
      float noise;
      
      /** Use noise */
      if( mSurface.mNoise != 0 ) {
          float f = mSurface.mNoise;
          // Noise goes from [-1,1]. We move it to go on interval [0,1]
          noise = (1.0 + noise_3d( _P.x*f, _P.y*f, _P.z*f ) ) / 2.0;        
          
          float diff[] = new float[3];
          diff[0] = mSurface.mDiff[0]*noise;
          diff[1] = mSurface.mDiff[1]*noise;
          diff[2] = mSurface.mDiff[2]*noise;
          return diff;
          
      }
                 
       /** Use marble */
       // Ideas from: http://www.cs.uml.edu/~haim/teaching/cg/resources/presentations/427/texture_mapping.pdf
      else if( mSurface.mMaterialType == sMarbleType ) { 
         float val = _P.x + 3.0*turbulence( _P.x, _P.y, _P.z );      
         noise = sin( 3.14157*val );
         return marble_color( noise );     
      }   
     
     /** Use wood */
     else if( mSurface.mMaterialType == sWoodType ) {
     
       // Cylindric coordinates
       float s = atan2( _P.y, _P.x );
       if( s < 0 ) { s =  s + 2.0*3.14157; }
       s = s / (2*3.1416);
       float t = _P.z;
       t = abs(t) / mR;
       
       
       float r = sqrt( abs(_P.x*_P.x) + abs(_P.y*_P.y) );
       if( r > 1 && r < 1.0001 ) { r = 1; } // clamp
       r = r / mR;

       float f = 1.0;
       float A = 0.25;
       noise = noise_3d( f*_P.x, f*_P.y, f*_P.z );      
       return wood_color( r + A*(noise) );
       
     } 

     /** Use stone */
     else if( mSurface.mMaterialType == sStoneType ) {
     float[] diff = new float[3];
     worley_noise wn = new worley_noise();
     float[] dist = wn.get_noise( _P.x, _P.y, _P.z );
     return stone_color( dist ); 
     }     
                 
                 
      else {
        return mSurface.mDiff;        
      }
      

    }
    
  }
  
  
    /** get Diffuse color when using mipMap */
  float[] getDiff( pt _P, rayMipMap _R ) {
    
    if(  mSurface.mIsTextured == true ) {

      // Check that all points are in the object
      if( _R.oUp.is_set() == false || _R.oRight.is_set() == false ){
        return getDiff( _P );
      }  
      // Check that both fall in the same object (supposedly this one)
      if( _R.oUp.objIndex != _R.oRight.objIndex ) {
        return getDiff( _P );
        
      }
      
      // Now we can proceed
      float tuv[] = new float[2]; tuv = get_tuv( _P );
      float tu = tuv[0]; float tv = tuv[1];
      
      // Get the other 2 coordinates
      float tuv1[] = new float[2]; tuv1 = get_tuv( _R.oUp.P );
      float tu1 = tuv1[0]; float tv1 = tuv1[1];

      float tuv2[] = new float[2]; tuv2 = get_tuv( _R.oRight.P );
      float tu2 = tuv2[0]; float tv2 = tuv2[1];

      // Get distance between points
      float dist1 = sqrt( (tu-tu1)*(tu-tu1) + (tv-tv1)*(tv-tv1) );
      float dist2 = sqrt( (tu-tu2)*(tu-tu2) + (tv-tv2)*(tv-tv2) );
      
      PVector uvd = new PVector();
      uvd.x = tu; uvd.y = tv;
      if( dist1 > dist2 ) { uvd.z = dist1; } else { uvd.z = dist2; }
      
      PVector c = mSurface.mTexture.color_value( uvd ); 
      float col[] = new float[3]; 
      col[0] = c.x / 255.0; col[1] = c.y / 255.0; col[2] = c.z / 255.0;
      return col;

    }  
      
    else {  
      return mSurface.mDiff;
    }
  }
 

  /** Get tuv : Coordinates of textures in [0 1] range */
  float[] get_tuv( pt _P ) {
  
    float tuv[] = new float[2];
  
      float dx = _P.x - mC.x;
      float dy = _P.y - mC.y;
      float dz = _P.z - mC.z;
      
      float theta = atan2( -dy, dx );
      float u = (theta + 3.1416 ) / (2*3.1416);
      float phi = acos( dz / mR );
      float vi = phi / 3.1416;

      tuv[0]= u;
      tuv[1] = vi;

    return tuv;
      
  }
  
  
  /**
   * @function printInfo
   */
  void printInfo() {
    print("\t Primitive: Sphere \n");
    print( "\t C: " + mC.x + "," + mC.y + ", " + mC.z + "\n" );
    print( "\t R: " + mR + "\n" );
    
    mSurface.printInfo();
  }
  
};

/**********************
 * @class Instance
 **********************/
class Instance extends Primitive {
  
  public int  mPInd;
  public PMatrix3D mTwo;
  public PMatrix3D mTow;
  
  /**< Constructor */
  Instance() {
    super( sInstanceType );
    mPInd = -1; 
    mTwo = new PMatrix3D();
    mTow = new PMatrix3D();
  }

  /**< Constructor 2*/
  Instance( int _ind, PMatrix3D _Two ) {
    super( sInstanceType );
    mPInd = _ind; 
    mTwo = _Two.get();
    mTow = mTwo.get(); mTow.invert();
    print("mTwo: ");
    mTwo.print();
    print("mTow: ");
    mTow.print();    
  }
  
  /**< Get surface */
  Surface getSurface() {
    return gNamedPrimitives[mPInd].getSurface();
  }  
    
    
  /** get Diffuse color */
  float[] getDiff( pt _P ) {
    
    // Convert point to canonical one
    PVector P = new PVector( _P.x, _P.y, _P.z ); 
    PVector Pcan = new PVector();
    mTow.mult( P, Pcan ); 
    pt Pn = new pt( Pcan.x, Pcan.y, Pcan.z );
   
    return gNamedPrimitives[mPInd].getDiff( Pn );
  }
  
  /** get Ambience color */
  float[] getAmb() {
    return gNamedPrimitives[mPInd].getAmb();
  }

  /**< hit function */
  boolean hit( ray _R, hitRecord _rec ) {
   PVector res = new PVector();
   PVector p1 = new PVector( _R.P.x, _R.P.y, _R.P.z );
   float[] p2 = new float[4]; p2[0] = _R.T.x; p2[1] =  _R.T.y; p2[2] =  _R.T.z; p2[3] = 0;
   float[] res2 = new float[4];
   mTow.mult( p1, res ); 
   mTow.mult( p2, res2 );
   
   pt P2 = new pt( res.x, res.y, res.z ); vec V2 = new vec(res2[0], res2[1], res2[2]);
   ray R = new ray(); R.set( P2, V2 );
   boolean b = gNamedPrimitives[mPInd].hit( R, _rec );
    
    if( b == true ) {
    PMatrix3D mt = mTow.get(); mt.transpose();
    
    PVector res3 = new PVector();
    PVector p3 = new PVector( _R.P.x + _R.T.x*_rec.dist, _R.P.x + _R.T.y*_rec.dist, _R.P.x + _R.T.z*_rec.dist );

    _rec.point = new pt( p3.x, p3.y, p3.z );
    
    PVector n4 = new PVector( _rec.normal.x, _rec.normal.y, _rec.normal.z );
    PVector res4 = new PVector();
    mt.mult(n4, res4);
    _rec.normal.x = res4.x; _rec.normal.y = res4.y; _rec.normal.z = res4.z; 
    }
    
    return b;
  }

  /** @function copyData */
  void copyData( Instance _instance ) {
    mPInd = _instance.mPInd;
    mTwo = _instance.mTwo;
    mTow = _instance.mTow;
  }

  /**
   * @function printInfo
   */
  void printInfo() {
    print("Primitive Instance \n");
    print("Two: \n");
    mTwo.print();
    print("Tow: \n");
    mTow.print();
    print("Global primitive index: " + mPInd + "\n");
  }
  
};





/***********************
 * @class hitRecord
 ***********************/
class hitRecord {
  public float dist;
  public pt point;
  public vec normal;  
}

/******************************
 * @class Light
 ******************************/
class Light {
  public pt mPos = new pt();
  public float[] mRGB = new float[3];
  public int mType;
  
  /**Constructor */
  Light() {
    mType = sPointLight;
  }
  
  int getType() { return mType; }
  
  /** Set position */
  void setPos( float _x, float _y, float _z ) {
    mPos.set(_x, _y, _z);
  }
  
  /** Set color */
  void setRGB( float _r, float _g, float _b ) {
    mRGB[0] = _r; mRGB[1] = _g; mRGB[2] = _b;
  }
  
   /**
    * @function calc_shadow_ray
    */
   ray calc_shadow_ray( pt _P ) {
     vec normal = V(_P, mPos).normalize();
     ray R = new ray( ); 
     R.set( P(_P, 0.02, normal ), normal  );
     return R;
   }

  /**
   * @function printInfo
   */
  void printInfo() {
    print( "\t Pos: "+ mPos.x + "," + mPos.y + ", " + mPos.z + "\n" );
    print( "\t Color: "+ mRGB[0] + "," + mRGB[1] + ", " + mRGB[2] + "\n" );    
  }

}

/**
 * @class DiskLight
 */
class DiskLight extends Light {

  public vec mN; /**< Normal */
  public float mR; /**< Radius */
  
  DiskLight() {
    mType = sDiskLight;
    mN = new vec();
  }
  
  void setNormal( float _Nx, float _Ny, float _Nz ) {
    mN.x = _Nx; mN.y = _Ny; mN.z = _Nz;
  }
  
  void setRadius( float _r ) {
    mR = _r;
  }
  
   /**
    * @function calc_shadow_ray
    */
   ray calc_shadow_ray( pt _P ) {
     // Hack to verify that it works. We know that normal is always towards X (I am being lazy here, but the
     // only hack so far is to do the randomization simpler in plane YZ - UPDATE THIS!)
     pt pin = new pt();
     float dr = sqrt( (float)Math.random() );
     float dt = 2*3.14157*(float)Math.random();
     pin.x = mPos.x;
     pin.y = mPos.y + mR*dr*cos(dt);
     pin.z = mPos.z + mR*dr*sin(dt);     
     
     vec normal = V(_P, pin).normalize();
     ray R = new ray(); 
     R.set( P(_P, 0.02, normal ), normal  );
     return R;
   }
  
}
  
 
