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

  Instance( int _ind, PMatrix3D _Two ) {
    super( sInstanceType );
    mPInd = _ind; 
    mTwo = _Two.get();
    mTow = mTwo.get(); mTow.invert();

    setDiffuseCoeff( gNamedPrimitives[mPInd].mDiff[0], gNamedPrimitives[mPInd].mDiff[1], gNamedPrimitives[mPInd].mDiff[2] );
    setAmbienceCoeff( gNamedPrimitives[mPInd].mAmb[0], gNamedPrimitives[mPInd].mAmb[1], gNamedPrimitives[mPInd].mAmb[2] );
    
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
    //print("Intersect \n");
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
    setDiffuseCoeff( _instance.mDiff[0], _instance.mDiff[1], _instance.mDiff[2] );
    setAmbienceCoeff( _instance.mAmb[0], _instance.mAmb[1], _instance.mAmb[2] );
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

/****************************
 * @class Box
 ****************************/
class Box extends Primitive {
  
  public pt Pmin = new pt();
  public pt Pmax = new pt();
  
  /**< @function Constructor */
  Box() {
    super( sBoxType );

    Pmin.x = 0; Pmin.y = 0; Pmin.z = 0;
    Pmax.x = 0; Pmax.y = 0; Pmax.z = 0;    
  }

  /**< setBounds */
   void setBounds( pt min, pt max ) {
     Pmin.x = min.x; Pmin.y = min.y; Pmin.z = min.z;
     Pmax.x = max.x; Pmax.y = max.y; Pmax.z = max.z;     
   }
   
   void set( float xmin, float ymin, float zmin, float xmax, float ymax, float zmax ) {
     Pmin.x = xmin; Pmin.y = ymin; Pmin.z = zmin;
     Pmax.x = xmax; Pmax.y = ymax; Pmax.z = zmax;     
   }

  /** @function copyData */
  void copyData( Box _box ) {

    Pmin.x = _box.Pmin.x; Pmin.y = _box.Pmin.y; Pmin.z = _box.Pmin.z;
    Pmax.x = _box.Pmax.x; Pmax.y = _box.Pmax.y; Pmax.z = _box.Pmax.z;
    
    setDiffuseCoeff( _box.mDiff[0], _box.mDiff[1], _box.mDiff[2] );
    setAmbienceCoeff( _box.mAmb[0], _box.mAmb[1], _box.mAmb[2] );
  }
  
  /** @function hit */
  // Adapted from http://geomalgorithms.com/a06-_intersect-2.html
  boolean hit( ray _R, hitRecord _rec ) {
    float t1, t2, tnear, tfar;
    tnear = -1000; tfar = 1000;
    vec nx = new vec(); vec ny = new vec(); vec nz = new vec(); vec n = new vec();
    float ttemp;

    // Plane X    
    if( _R.T.x == 0 ) {
      if( _R.P.x < Pmin.x || _R.P.x > Pmax.x ) { return false; }
    }
    
    t1 = (Pmin.x - _R.P.x) / _R.T.x; 
    t2 = (Pmax.x - _R.P.x) / _R.T.x;      

    nx.x = -1; nx.y = 0; nx.z = 0;
    
    if( t1 > t2 ) { ttemp = t2; t2 = t1; t1 = ttemp; nx.x = +1; nx.y = 0; nx.z = 0; }
    if( t1 > tnear ) { tnear = t1; n = nx; }
    if( t2 < tfar ) { tfar = t2; }
    if( tnear > tfar ) { return false; }
    if( tfar < 0 ) { return false; }

    // Plane Y
    if( _R.T.y == 0 ) {
      if( _R.P.y < Pmin.y || _R.P.y > Pmax.y ) { return false; }
    }
    
    t1 = (Pmin.y - _R.P.y) / _R.T.y;
    t2 = (Pmax.y - _R.P.y) / _R.T.y;      

    ny.x = 0; ny.y = -1; ny.z = 0;
    
    if( t1 > t2 ) { ttemp = t2; t2 = t1; t1 = ttemp; ny.x = 0; ny.y = +1; ny.z = 0; }
    if( t1 > tnear ) { tnear = t1; n = ny; }
    if( t2 < tfar ) { tfar = t2; }
    if( tnear > tfar ) { return false; }
    if( tfar < 0 ) { return false; }

    // Plane Z
    if( _R.T.z == 0 ) {
      if( _R.P.z < Pmin.z || _R.P.z > Pmax.z ) { return false; }
    }
    
    t1 = (Pmin.z - _R.P.z) / _R.T.z;
    t2 = (Pmax.z - _R.P.z) / _R.T.z;      

    nz.x = 0; nz.y = 0; nz.z = -1;
    
    if( t1 > t2 ) { ttemp = t2; t2 = t1; t1 = ttemp; nz.x = 0; nz.y = 0; nz.z = +1; }
    if( t1 > tnear ) { tnear = t1; n = nz; }
    if( t2 < tfar ) { tfar = t2; }
    if( tnear > tfar ) { return false; }
    if( tfar < 0 ) { return false; }

    // Store hit record
    _rec.dist = tnear;
    _rec.point = P(_R.P, tnear, _R.T );
    _rec.normal = n;


    return true;
    
    
  }

  
};

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
     //print( "Test ray "+_R.P.x + " " + _R.P.y + " " + _R.P.z + " T: " + _R.T.x +  " " + _R.T.y + " " + _R.T.z + "\n");
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


  
 
