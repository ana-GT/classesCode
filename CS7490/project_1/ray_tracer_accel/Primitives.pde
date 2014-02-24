/**********************
 * @class Primitive
 ***********************/
class Primitive {
  public int mType;  
  
  public float[] mDiff = new float[3];
  public float[] mAmb = new float[3];
  
  Box bb;

  Primitive() { mType = sDefaultType; }
  Primitive( int _type ) { mType = _type; }

  /**Return type */
  int getType() { return mType; }
  
  void copyData( Primitive _p ) {};
  
  boolean hit( ray _R, hitRecord _rec ) { 
    //print("[hit] ONLY CALLED WHEN PRIMITIVE NOT INITIALIZED TO A TYPE!! \n");
    return false; 
  }

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
  
  /**< Get bounding box */
  float[] getDim_BB() {
    float[] b = new float[6];
    b[0] = bb.Pmin[0]; b[1] = bb.Pmin[1]; b[2] = bb.Pmin[2];
    b[3] = bb.Pmax[0]; b[4] = bb.Pmax[1]; b[5] = bb.Pmax[2];   
    return b; 
  }
  
  Box boundingBox() { return bb; }
  
  /**< Calculate bounding box */
  boolean initBB() { return true; };
  
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

  /**< Constructor 2*/
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
 * @class List
 ****************************/
class List extends Primitive {

  public int MAX_NUM_PRIMITIVES = 1600;   
  public int mSize;
  public Primitive[] mObjects = new Primitive[MAX_NUM_PRIMITIVES];
  
  
  List() {
    super( sListType );
    bb = new Box();
    mSize = 0;
    
    for( int i = 0; i < MAX_NUM_PRIMITIVES; ++i ) {
        mObjects[i] = new Primitive();
    }
  }
  
  /** @function copyData */
  void copyData( List _list ) {
    mSize = 0;

    for( int i = 0; i < _list.mSize; ++i ) {
      if( _list.mObjects[i].getType() == sTriangleType ) { 
        addObject( (Triangle)_list.mObjects[i] ); 
      }      
    }
    

    setDiffuseCoeff( _list.mDiff[0], _list.mDiff[1], _list.mDiff[2] );
    setAmbienceCoeff( _list.mAmb[0], _list.mAmb[1], _list.mAmb[2] );
  }
  
  /**< addObject */
  void addObject( Primitive _p ) {

      if( _p.getType() == sSphereType ) {
        mObjects[mSize] = (Sphere)_p;        
      } 
      else if( _p.getType() == sTriangleType ) {
        mObjects[mSize] = (Triangle)_p;        
      } 
      else if( _p.getType() == sInstanceType ) {
        mObjects[mSize] = (Instance)_p;        
      } 
      else if( _p.getType() == sBoxType ) {
        mObjects[mSize] = (Box)_p;        
      } 
      else if( _p.getType() == sListType ) {
        mObjects[mSize] = (List)_p;           
      }    
    mSize++;
  }
  
  /**< getSize */
  int getSize() { return mSize; }

  /**< setBoundingBox */
  boolean initBB() {
    
    bb.Pmin[0] = 1000; bb.Pmin[1] = 1000; bb.Pmin[2] = 1000;
    bb.Pmax[0] = -1000; bb.Pmax[1] = -1000; bb.Pmax[2] = -1000;
        
    float[] b = new float[6];
    
    // Go through all bounding boxes of the objects and get the bounding box for this guy
    for( int i = 0; i < mSize; ++i ) {
       mObjects[i].initBB();
       b = mObjects[i].getDim_BB();
       if( bb.Pmin[0] > b[0] ) { bb.Pmin[0] = b[0]; } if( bb.Pmax[0] < b[3] ) { bb.Pmax[0] = b[3]; }
       if( bb.Pmin[1] > b[1] ) { bb.Pmin[1] = b[1]; } if( bb.Pmax[1] < b[4] ) { bb.Pmax[1] = b[4]; }
       if( bb.Pmin[2] > b[2] ) { bb.Pmin[2] = b[2]; } if( bb.Pmax[2] < b[5] ) { bb.Pmax[2] = b[5]; }

    }
    
    return true;
  }


    /**< hit function */
  boolean hit( ray _R, hitRecord _rec ) {

    hitRecord hr = new hitRecord();
    
    if( !bb.hit( _R, hr ) ) { return false; }
    else {

      double minDist = 1000;
      int minInd = -1;
      boolean got = false;

      for( int i = 0; i < mSize; ++i ) {
      
        if( ((Triangle)mObjects[i]).hit( _R, hr ) == true ) {
            got = true;
            if( hr.dist < minDist ) {
                minDist = hr.dist;
                minInd = i;
                _rec.copyData(hr);
            } 
        }
        
      }
      
      if( got ) {
          mDiff = mObjects[minInd].mDiff;
          mAmb = mObjects[minInd].mAmb;
      }
      return got;
    }  

  }
  
  
};


/**********************
 * @class BVH
 ***********************/
class BVH extends Primitive {
  
  public int mAxis;
  
  public Primitive left;
  public Primitive right;
  
  /**< Constructor */
  
  /**< Constructor with objects in tow */
  BVH( Primitive[] _objs, int _axis ) {
    super( sBVHType );
    bb = new Box();
    mAxis = _axis;
    left = new Primitive();
    right = new Primitive();
    initBB( _objs );

  // HACK BECAUSE I KNOW ALL OF THEM ARE TRIANGLES!
    // If only one member, set left node
    if( _objs.length == 1 ) {
       left = (Triangle)_objs[0];
        mAmb = left.mAmb;
        mDiff = left.mDiff;
       
     } else if( _objs.length == 2 ) {
       left = (Triangle)_objs[0];
       right = (Triangle)_objs[1];
     } else {       

       Triangle[][] parts= partition( _objs ); 
       if( parts[0].length > 0 ) {
         left = new BVH( parts[0], (mAxis + 1) % 3 );
       }
       if( parts[1].length > 0 ) { 
         right = new BVH( parts[1], (mAxis + 1) %3 );       
       }

     }

    
  }
  
  /**< copyData: NO IMPLEMENTED!!!!!! */
  void copyData( BVH _bvh ) { print("COPY DATA BVH NO IMPLEMENTED ARGH!!!! \n");}
  
  /**< init : Initialize BVH in tree-like organization */
  boolean initBB( Primitive[] _objs ) {

    bb.Pmin[0] = 1000; bb.Pmin[1] = 1000; bb.Pmin[2] = 1000;
    bb.Pmax[0] = -1000; bb.Pmax[1] = -1000; bb.Pmax[2] = -1000;
        
    float[] b = new float[6];
    
    // Go through all bounding boxes of the objects and get the bounding box for this guy
    for( int i = 0; i < _objs.length; ++i ) {
       b = _objs[i].getDim_BB();
       if( bb.Pmin[0] > b[0] ) { bb.Pmin[0] = b[0]; } if( bb.Pmax[0] < b[3] ) { bb.Pmax[0] = b[3]; }
       if( bb.Pmin[1] > b[1] ) { bb.Pmin[1] = b[1]; } if( bb.Pmax[1] < b[4] ) { bb.Pmax[1] = b[4]; }
       if( bb.Pmin[2] > b[2] ) { bb.Pmin[2] = b[2]; } if( bb.Pmax[2] < b[5] ) { bb.Pmax[2] = b[5]; }

    }
    
    return true;

  }
  
  /**< Partition list of objects in left and right around the middle of the axis */
  Triangle[][] partition( Primitive[] _objs ) {
    Triangle[][] parts = new Triangle[2][];
    // Find m: Middle point in axis mAxis:
    float m;
    int n = _objs.length;
    m = ( bb.Pmin[mAxis] + bb.Pmax[mAxis] ) / 2.0; 
        
    // Partition
    Triangle[] tleft = new Triangle[n];
    Triangle[] tright = new Triangle[n];    
    int counter_left = 0;
    int counter_right = 0;
    
    // HACK BECAUSE I KNOW ALL OBJECTS ARE TRIANGLE ARGH!!! FIX THE TRIANGLE SETTING
    float p;
    for( int i = 0; i < n; ++i ) {
      p = ( _objs[i].bb.Pmax[mAxis] + _objs[i].bb.Pmin[mAxis] ) / 2.0;
      if( p < m ) { 
        tleft[counter_left] = (Triangle)_objs[i];
        counter_left++; 
      } else {
        tright[counter_right] = (Triangle)_objs[i]; 
        counter_right++;
      }    
    }
    
    // Now put the elements into pleft and pright
    Triangle[] pleft = new Triangle[counter_left];
    Triangle[] pright = new Triangle[counter_right];    
    for( int i = 0; i < counter_left; ++i ) {
      pleft[i] = (Triangle) tleft[i];
    }

    for( int i = 0; i < counter_right; ++i ) {
      pright[i] = (Triangle) tright[i];
    }
   
   parts[0] = pleft;
   parts[1] = pright; 
  
    return parts;
  }

  
  /**< hit */
  boolean hit( ray _R, hitRecord _rec ) { 
    
    if( bb.hit( _R, _rec ) ) {
      hitRecord lrec = new hitRecord();
      hitRecord rrec = new hitRecord();
      boolean left_hit, right_hit;
      
      left_hit = left.hit( _R, lrec );
      right_hit = right.hit( _R, rrec );
      if( left_hit && right_hit ) {
        if( lrec.dist < rrec.dist ) {
          _rec.copyData(lrec);
        } else {
          _rec.copyData(rrec);
        }        
        mAmb[0] = _rec.amb[0]; mAmb[1] = _rec.amb[1]; mAmb[2] = _rec.amb[2];
        mDiff[0] = _rec.diff[0]; mDiff[1] = _rec.diff[1]; mDiff[2] = _rec.diff[2];
        return true;
      } else if( left_hit ) {
        _rec.copyData(lrec);
        mAmb[0] = _rec.amb[0]; mAmb[1] = _rec.amb[1]; mAmb[2] = _rec.amb[2];
        mDiff[0] = _rec.diff[0]; mDiff[1] = _rec.diff[1]; mDiff[2] = _rec.diff[2];
        return true;
      } else if( right_hit ) {
        _rec.copyData(rrec);
        mAmb[0] = _rec.amb[0]; mAmb[1] = _rec.amb[1]; mAmb[2] = _rec.amb[2];
        mDiff[0] = _rec.diff[0]; mDiff[1] = _rec.diff[1]; mDiff[2] = _rec.diff[2];
        return true;
      } else {
        return false;
      }
      
      
    } 
    // If BB was not hit at all. YEAH WE DON'T DO ANY CALCULATION!
    else {
      return false;
    }
    
    
  }
  
  
  void printInfo() {
  }

  
  
};

/**< combine: Get the bounding box from two bounding boxes */
Box combine( Box _left, Box _right ) {

  Box b = new Box();
  if( _left.Pmin[0] < _right.Pmin[0] ) { b.Pmin[0] = _left.Pmin[0]; } else { b.Pmin[0] = _right.Pmin[0]; }
  if( _left.Pmin[1] < _right.Pmin[1] ) { b.Pmin[1] = _left.Pmin[1]; } else { b.Pmin[1] = _right.Pmin[1]; }
  if( _left.Pmin[2] < _right.Pmin[2] ) { b.Pmin[2] = _left.Pmin[2]; } else { b.Pmin[2] = _right.Pmin[2]; }  
  
  if( _left.Pmax[0] > _right.Pmax[0] ) { b.Pmax[0] = _left.Pmax[0]; } else { b.Pmax[0] = _right.Pmax[0]; }
  if( _left.Pmax[1] > _right.Pmax[1] ) { b.Pmax[1] = _left.Pmax[1]; } else { b.Pmax[1] = _right.Pmax[1]; }
  if( _left.Pmax[2] > _right.Pmax[2] ) { b.Pmax[2] = _left.Pmax[2]; } else { b.Pmax[2] = _right.Pmax[2]; }  
  
  return b;
}

/****************************
 * @class Box
 ****************************/
class Box extends Primitive {
  
  public float[] Pmin = new float[3];
  public float[] Pmax = new float[3] ;
  
  /**< @function Constructor */
  Box() {
    super( sBoxType );

    Pmin[0] = 0; Pmin[1] = 0; Pmin[2] = 0;
    Pmax[0] = 0; Pmax[1] = 0; Pmax[2] = 0;    
  }

  /**< setBounds */
   void setBounds( pt min, pt max ) {
     Pmin[0] = min.x; Pmin[1] = min.y; Pmin[2] = min.z;
     Pmax[0] = max.x; Pmax[1] = max.y; Pmax[2] = max.z;     
   }
   
   void set( float xmin, float ymin, float zmin, float xmax, float ymax, float zmax ) {
     Pmin[0] = xmin; Pmin[1] = ymin; Pmin[2] = zmin;
     Pmax[0] = xmax; Pmax[1] = ymax; Pmax[2] = zmax;     
   }

  /** @function copyData */
  void copyData( Box _box ) {

    Pmin[0] = _box.Pmin[0]; Pmin[1] = _box.Pmin[1]; Pmin[2] = _box.Pmin[2];
    Pmax[0] = _box.Pmax[0]; Pmax[1] = _box.Pmax[1]; Pmax[2] = _box.Pmax[2];
    
    setDiffuseCoeff( _box.mDiff[0], _box.mDiff[1], _box.mDiff[2] );
    setAmbienceCoeff( _box.mAmb[0], _box.mAmb[1], _box.mAmb[2] );
  }
  
  /** @function hit */
  boolean hit( ray _R, hitRecord _rec ) {
    float t1, t2, tnear, tfar;
    tnear = -1000; tfar = 1000;
    vec nx = new vec(); vec ny = new vec(); vec nz = new vec(); vec n = new vec();
    float ttemp;

    // Plane X    
    if( _R.T.x == 0 ) {
      if( _R.P.x < Pmin[0] || _R.P.x > Pmax[0] ) { return false; }
    }
    
    t1 = (Pmin[0] - _R.P.x) / _R.T.x; 
    t2 = (Pmax[0] - _R.P.x) / _R.T.x;      

    nx.x = -1; nx.y = 0; nx.z = 0;
    
    if( t1 > t2 ) { ttemp = t2; t2 = t1; t1 = ttemp; nx.x = +1; nx.y = 0; nx.z = 0; }
    if( t1 > tnear ) { tnear = t1; n = nx; }
    if( t2 < tfar ) { tfar = t2; }
    if( tnear > tfar ) { return false; }
    if( tfar < 0 ) { return false; }

    // Plane Y
    if( _R.T.y == 0 ) {
      if( _R.P.y < Pmin[1] || _R.P.y > Pmax[1] ) { return false; }
    }
    
    t1 = (Pmin[1] - _R.P.y) / _R.T.y;
    t2 = (Pmax[1] - _R.P.y) / _R.T.y;      

    ny.x = 0; ny.y = -1; ny.z = 0;
    
    if( t1 > t2 ) { ttemp = t2; t2 = t1; t1 = ttemp; ny.x = 0; ny.y = +1; ny.z = 0; }
    if( t1 > tnear ) { tnear = t1; n = ny; }
    if( t2 < tfar ) { tfar = t2; }
    if( tnear > tfar ) { return false; }
    if( tfar < 0 ) { return false; }

    // Plane Z
    if( _R.T.z == 0 ) {
      if( _R.P.z < Pmin[2] || _R.P.z > Pmax[2] ) { return false; }
    }
    
    t1 = (Pmin[2] - _R.P.z) / _R.T.z;
    t2 = (Pmax[2] - _R.P.z) / _R.T.z;      

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
    bb = new Box();  
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
  
  /** ........................*/  
  /**< Calculate bounding box */
  /** ........................*/    
  boolean initBB() { 
    bb.Pmin[0] = 1000; bb.Pmin[1] = 1000; bb.Pmin[2] = 1000;
    bb.Pmax[0] = -1000; bb.Pmax[1] = -1000; bb.Pmax[2] = -1000;
    
    if( mV[0].x < bb.Pmin[0] ) { bb.Pmin[0] = mV[0].x; }  if( mV[0].x > bb.Pmax[0] ) { bb.Pmax[0] = mV[0].x; }
    if( mV[1].x < bb.Pmin[0] ) { bb.Pmin[0] = mV[1].x; }  if( mV[1].x > bb.Pmax[0] ) { bb.Pmax[0] = mV[1].x; } 
    if( mV[2].x < bb.Pmin[0] ) { bb.Pmin[0] = mV[2].x; }  if( mV[2].x > bb.Pmax[0] ) { bb.Pmax[0] = mV[2].x; } 

    if( mV[0].y < bb.Pmin[1] ) { bb.Pmin[1] = mV[0].y; }  if( mV[0].y > bb.Pmax[1] ) { bb.Pmax[1] = mV[0].y; }
    if( mV[1].y < bb.Pmin[1] ) { bb.Pmin[1] = mV[1].y; }  if( mV[1].y > bb.Pmax[1] ) { bb.Pmax[1] = mV[1].y; } 
    if( mV[2].y < bb.Pmin[1] ) { bb.Pmin[1] = mV[2].y; }  if( mV[2].y > bb.Pmax[1] ) { bb.Pmax[1] = mV[2].y; } 

    if( mV[0].z < bb.Pmin[2] ) { bb.Pmin[2] = mV[0].z; }  if( mV[0].z > bb.Pmax[2] ) { bb.Pmax[2] = mV[0].z; }
    if( mV[1].z < bb.Pmin[2] ) { bb.Pmin[2] = mV[1].z; }  if( mV[1].z > bb.Pmax[2] ) { bb.Pmax[2] = mV[1].z; } 
    if( mV[2].z < bb.Pmin[2] ) { bb.Pmin[2] = mV[2].z; }  if( mV[2].z > bb.Pmax[2] ) { bb.Pmax[2] = mV[2].z; } 

    
    return true; 
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
       
        _rec.amb[0] = mAmb[0]; _rec.amb[1] = mAmb[1]; _rec.amb[2] = mAmb[2];
        _rec.diff[0] = mDiff[0]; _rec.diff[1] = mDiff[1]; _rec.diff[2] = mDiff[2];
        
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
 * @class hitRecord
 ***********************/
class hitRecord {
  public float dist;
  public pt point;
  public vec normal;  
  float[] amb = new float[3];
  float[] diff = new float[3];
  
  /**< copyData */
  void copyData( hitRecord _hr ) {
    dist = _hr.dist;
    point = new pt( _hr.point.x, _hr.point.y, _hr.point.z );
    normal = new vec( _hr.normal.x, _hr.normal.y, _hr.normal.z );  
    amb[0] = _hr.amb[0]; amb[1] = _hr.amb[1]; amb[2] = _hr.amb[2];
    diff[0] = _hr.diff[0]; diff[1] = _hr.diff[1]; diff[2] = _hr.diff[2];    
  }
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


  
 
