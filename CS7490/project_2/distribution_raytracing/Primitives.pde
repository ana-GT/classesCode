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
  
  boolean hit( ray _R, hitRecord _rec ) { print("I SHOULD NOT BE CALLED \n");return false; }

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
    mC.x = _sphere.mC.x; mC.y = _sphere.mC.y; mC.z = _sphere.mC.z;
    print("Center: " + mC.x + " " + mC.y + " " + mC.z + "\n");
    mR = _sphere.mR;
    setDiffuseCoeff( _sphere.mDiff[0], _sphere.mDiff[1], _sphere.mDiff[2] );
    setAmbienceCoeff( _sphere.mAmb[0], _sphere.mAmb[1], _sphere.mAmb[2] );
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

/***********************
 * @class MovingSphere
 ***********************/
class MovingSphere extends Sphere {

  public pt mC0; /** Minimum position */
  public pt mC1; /** Maximum position */
  public vec mdC; /** Rate of change between mC0 and mC1 */
  
  /** Constructor */
  MovingSphere() {
    mType = sMovingSphereType;
    mC = new pt();
    mR = 1;
    mC0 = new pt(); mC1 = new pt();
    mdC = new vec();
  }

  /** Set values */  
  void set( float _r, float _x0, float _y0, float _z0, float _x1, float _y1, float _z1 ) {
    mC0.set( _x0, _y0, _z0 );
    mC1.set( _x1, _y1, _z1 );
    mdC = new vec( mC1.x - mC0.x, mC1.y - mC0.y, mC1.z - mC0.z );
    mC.set( 0.5*(mC0.x + mC1.x), 0.5*(mC0.y + mC1.y), 0.5*(mC0.z + mC1.z) );

    mR = _r;
  }
  
  /** copyData */ /*
  void copyData( Sphere _sphere ) {
    mC.x = _sphere.mC.x; mC.y = _sphere.mC.y; mC.z = _sphere.mC.z;
    print("Center: " + mC.x + " " + mC.y + " " + mC.z + "\n");
    mR = _sphere.mR;
    setDiffuseCoeff( _sphere.mDiff[0], _sphere.mDiff[1], _sphere.mDiff[2] );
    setAmbienceCoeff( _sphere.mAmb[0], _sphere.mAmb[1], _sphere.mAmb[2] );
  } */


    /** @function hit */
  boolean hit( ray _R, hitRecord _rec ) { 
 
     // Generate a position between 0 and 1
     float dt = (float)( Math.random() );
     mC = P( mC0, dt, mdC );
    
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
  
}

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
  
 
