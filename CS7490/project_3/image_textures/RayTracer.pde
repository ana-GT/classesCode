/**
 * @class Raytracer
 */
 class RayTracer {
   
   public float mFov;
   public pt mE; /** Eye. Default 0,0,0*/
   public float mf; /** Focal distance */
   public int mnx;
   public int mny;
   public int mnx_2;
   public int mny_2;   
   public float mdx;
   public float mdy;
   public int mNumRaysPerPixel;
   public float mRadius;
   public float mFocalDist;
   public boolean mSetLensFlag;
   
   public float mMinDist; int mMinInd; pt mMinPoint; vec mMinNormal;
   
   /** Constructor */
   RayTracer(){
     mFov = 60;
     mf = 1.0;
     mnx = 300;
     mny = 300;
     mnx_2 = mnx / 2;
     mny_2 = mny / 2;    
     mE = new pt(0,0,0); 

     reset();
   }

  /** Set FOV IN RADIANS! */   
   void setFov( float _fov ) { mFov = radians(_fov); } 
   
   /**< Set Lens flag */
   void setLens( float _radius, float _focalDist ) {
     mRadius = _radius;
     mFocalDist = _focalDist;
     mSetLensFlag = true;
   }
   
   /** Set Pixels Dim */
   void setPixelDims( int _width, int _height ) {
     mnx = _width;
     mny = _height;
     mnx_2 = mnx / 2;
     mny_2 = mny / 2;
     
   }
   
   /** Init */
   void init() {
     mdx = mf*tan(mFov/2) / mnx_2;
     mdy = mf*tan(mFov/2) / mny_2;     
   }
   
   /** Reset */
   void reset() {
     mMinDist = 1000;
     mMinInd = -1;
     mMinNormal = new vec( 0, 0, 0 );
     mNumRaysPerPixel = 1;
     mSetLensFlag = false;
   }
   
    /**
     * @function setRaysPerPixel
     */
    void setRaysPerPixel( int _num ) {
      mNumRaysPerPixel = _num;
    }
   
   /**
    * @function render 
    * @brief Ray trace the scene - High-level
    */
   void render() {
   
     int[] pixelColor = new int[3];
     
     // For each pixel x,y
     for( int x = 0; x < mnx; ++x ) {
       for( int y =0; y < mny; ++y ) {
         if( mNumRaysPerPixel == 1 ) {
           ray R = ray_through_pixel( x,y, true );
           pixelColor = Trace( R, 0 );
         } else {
           pixelColor[0] = 0; pixelColor[1] = 0; pixelColor[2] = 0;
           int[] temp = new int[3];
           // Generate random rays
           for( int i = 0; i < mNumRaysPerPixel; ++i ) {
             ray R = ray_through_pixel( x,y, false );
             temp = Trace( R, 0 );
             pixelColor[0] = pixelColor[0] + temp[0];
             pixelColor[1] = pixelColor[1] + temp[1];
             pixelColor[2] = pixelColor[2] + temp[2];             
           }        
           // Average the color
           pixelColor[0] = (int)( (float) pixelColor[0] / (float) mNumRaysPerPixel );
           pixelColor[1] = (int)( (float) pixelColor[1] / (float) mNumRaysPerPixel );
           pixelColor[2] = (int)( (float) pixelColor[2] / (float) mNumRaysPerPixel );           
         }
         fill( pixelColor[0], pixelColor[1], pixelColor[2] );
         rect( x, y, 1, 1 );
       }
     }
         
   }
   
   /**
    * @function Trace
    * @brief Check if there is ray intersection. If so, shade it, if not put background color
    */
   int[] Trace( ray _R, int _depth ) {
     
      ray newR = new ray();
     
       // If using depth effect
      if( mSetLensFlag == true ) {
      // 1. Find intersection of ray with plane focal
       float t = ( -mFocalDist - _R.P.z ) / ( _R.T.z );    
       pt Fp = P( _R.P, t, _R.T );
       
       // 2. Randomize a point around the lens (eye)
       pt deye = new pt();
       float dr = sqrt( (float)Math.random() );
       float dt = 2*3.14157*(float)Math.random();
       deye.x = _R.P.x + mRadius*dr*cos(dt);
       deye.y = _R.P.y + mRadius*dr*sin(dt);
       deye.z = _R.P.z;     
     
       // Use as ray the ray between point in focal plane and randomized lens point
       vec newV = new vec(Fp.x - deye.x, Fp.y - deye.y, Fp.z - deye.z);
       newR.set( deye, newV );
     
      } else {
        newR = _R;
      }
      
      
     objPt object_point =  new objPt();
     object_point = closest_intersection( newR );
     if( object_point.is_set() ) {
       return Shade( object_point, newR, _depth );
     } else {
        return gEnv.mBgColorInt;
     }

   }
   
   /**
    * @function closest_intersection
    * @brief Returns the index of the object first intersected by _R and the incident point
    */
   objPt closest_intersection( ray _R ) {
     
     objPt object_point = new objPt();
     object_point.objIndex = -1; // PROBABLY NOT NEEDED BUT JUST TO DEBUG  

    // Init minDist
     mMinDist = 1000; 
     mMinInd = -1; 
     mMinNormal = new vec(0,0,0);

    // Go through all primitives AFTER setting default minDist and minInd
     for( int i = 0; i < gEnv.mNumPrimitives; ++i ) {
       intersect( _R, i );
     }
     
     if( mMinInd != -1 ) { 
       object_point.objIndex = mMinInd; 
       object_point.P = mMinPoint; 
       object_point.N = mMinNormal.normalize();
     }
       
     return object_point;
   }
   

   /** 
    * @function intersect 
    */
   boolean intersect( ray _R, int i ) {

     hitRecord rec; 
     rec = new hitRecord();
     
    if( gEnv.mPrimitives[i].hit( _R, rec ) == true ) {
             
          if( rec.dist < mMinDist ) { 
             mMinDist = rec.dist; 
             mMinInd = i; 
             mMinPoint = rec.point; 
             mMinNormal = rec.normal;
           } // We normalize when assigning to mMinNormal
           return true;
    }
        
    return false;
     
   }

   
   /**
    * @function Shade
    * @brief Return the color of the pixel on surface 
    */
   int[] Shade( objPt _objPt, ray _R, int _depth ) {
     
     int pixelColor[] = new int[3];
     float radiance[] = new float[3];
     
     if( mMinInd != _objPt.objIndex ) { print ("Something fishy \n"); }
     float amb[] = gEnv.mPrimitives[_objPt.objIndex].getAmb();
     float diff[] = gEnv.mPrimitives[_objPt.objIndex].getDiff( _objPt.P );
                 
     // Ambient term     
     radiance[0] = amb[0]*1.0; radiance[1] = amb[1]*1.0;  radiance[2] = amb[2]*1.0;
     
     for( int i = 0; i < gEnv.mNumLights; ++i ) {
       ray shadow_ray = (gEnv.mLights[i]).calc_shadow_ray( _objPt.P );
       // If no in shadow 
       if( in_shadow( shadow_ray, gEnv.mLights[i] ) == false ) {
   
         // Diffuse term       
         float NL = abs( d( _objPt.N, shadow_ray.T ) );
         float Ilight[] = gEnv.mLights[i].mRGB;
    
         
         radiance[0] = radiance[0] + Ilight[0]*NL*diff[0];
         radiance[1] = radiance[1] + Ilight[1]*NL*diff[1];
         radiance[2] = radiance[2] + Ilight[2]*NL*diff[2];         
         
         // Shiny term         
         if( gEnv.mPrimitives[_objPt.objIndex].getSurface().getType() == sShinyType ) {
           
           float shiny[] = ((Shiny)gEnv.mPrimitives[_objPt.objIndex].getSurface()).mSpec;
           float specPower = ((Shiny)gEnv.mPrimitives[_objPt.objIndex].getSurface()).mSpecPower;
           
           vec Lm = shadow_ray.T; Lm.normalize();
           vec N = _objPt.N; N.normalize();
           vec V = V(-1,_R.T); V.normalize();
          
          vec H = A(Lm, V); H.normalize();
          float cost = d( N, H );
          if( cost < 0 ) { cost = 0; } 
          
           float ctn = (float)Math.pow( (double)cost, (double)specPower );       
           radiance[0] = radiance[0] + Ilight[0]*shiny[0]*ctn;
           radiance[1] = radiance[1] + Ilight[1]*shiny[1]*ctn;
           radiance[2] = radiance[2] + Ilight[2]*shiny[2]*ctn;     

           // If reflectance
           if( ((Shiny)gEnv.mPrimitives[_objPt.objIndex].getSurface()).isReflective() && _depth < MAX_DEPTH ) {   
               float Kref = ((Shiny)gEnv.mPrimitives[_objPt.objIndex].getSurface()).mKref;          
               // Get reflected ray
               ray reflectedRay = new ray();
               vec Vr = _R.T; Vr.normalize();
               float c1 = -2*d(Vr,N);
               vec dir = A( Vr, V( c1, N ) );
               dir.normalize();
               //vec dir = M( _R.T, V(2*d(_R.T,N), _R.T) ); dir.normalize();
               reflectedRay.set( P(_objPt.P, 0.005, dir), dir );
               int reflection255[] = Trace( reflectedRay, _depth + 1 );
               radiance[0] = radiance[0] + Kref*( (float)reflection255[0] / 255.0 );
               radiance[1] = radiance[1] + Kref*( (float)reflection255[1] / 255.0 );
               radiance[2] = radiance[2] + Kref*( (float)reflection255[2] / 255.0 );     
           }

         }
            

       }  
       else {
         // Nothing
       }
       
     }
     
     pixelColor[0] = (int)(255*radiance[0]);
     pixelColor[1] = (int)(255*radiance[1]);
     pixelColor[2] = (int)(255*radiance[2]);
     
     return pixelColor;
   }
   
   
   /**
    * @function calc_shadow_ray
    */
   ray calc_shadow_ray( pt _P, Light _L ) {
     vec normal = V(_P, _L.mPos).normalize();
     ray R = new ray( ); 
     R.set( P(_P, 0.02, normal ), normal  );
     return R;
   }
   
   /**
    * @function in_shadow
    * @brief True if there is an object blocking the way between the ray and the light
    * @TODO: Check that object is in the line between light and point, now we are only
    * checking that object is in the ray from point to infinity(most likely anyway but still...)
    */
   boolean in_shadow( ray _R, Light _L ) {
     for( int i = 0; i < gEnv.mNumPrimitives; ++i ) {
       if( intersect( _R, i ) == true ) { return true; }
     }
     
     return false;
   }
   
   /**
    * @function ray_through_pixel
    * @brief Returns a ray that goes from The Eye through pixel(x,y)
    * @TODO : It works with P 0,0,0, but should set T = PixelPos - Eye (Eye is zero by now so that works)
    */
   ray ray_through_pixel( int _x, int _y, boolean _centered ) {
     ray R = new ray();
     pt P = mE; /** Origin */

     // Generate a ray that goes exactly through the center of the pixel area
     float xvar; float yvar;
     if( _centered == true ) {
       xvar = 0.5; yvar = 0.5;
     } else {
       xvar = (float)Math.random(); yvar = (float)Math.random();
     }
     
       pt Pi = new pt( mdx*( -mnx_2 + _x + xvar), mdy*( mny_2 - _y - yvar ), -mf );
       vec T = V( P, Pi );
       R.set( P, T.normalize() );
     
     return R;
   }

   
   /**
    * @function printInfo
    */
   void printInfo() {
     print("\t FOV to " + mFov + "\n");
   }
   
 }
