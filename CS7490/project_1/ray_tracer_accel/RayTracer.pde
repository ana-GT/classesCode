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
     mMinDist = 1000;
     mMinInd = -1;
     mMinNormal = new vec( 0, 0, 0 );
   }

  /** Set FOV IN RADIANS! */   
   void setFov( float _fov ) { mFov = radians(_fov); } 
   
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
         ray R = ray_through_pixel( x,y );
         pixelColor = Trace( R );
         fill( pixelColor[0], pixelColor[1], pixelColor[2] );
         rect( x, y, 1, 1 );
       }
     }
         
   }
   
   /**
    * @function Trace
    * @brief Check if there is ray intersection. If so, shade it, if not put background color
    */
   int[] Trace( ray _R ) {
          
     objPt object_point =  new objPt();
     object_point = closest_intersection( _R );
     if( object_point.is_set() ) {
       return Shade( object_point, _R );
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
   int[] Shade( objPt _objPt, ray _R ) {
     
     int pixelColor[] = new int[3];
     float radiance[] = new float[3];
     
     float amb[] = gEnv.mPrimitives[mMinInd].mAmb;
     float diff[] = gEnv.mPrimitives[mMinInd].mDiff;
          
     // Ambient ligthing     
     radiance[0] = amb[0]*1.0;
     radiance[1] = amb[1]*1.0; 
     radiance[2] = amb[2]*1.0;
     
     for( int i = 0; i < gEnv.mNumLights; ++i ) {
       ray shadow_ray = calc_shadow_ray( _objPt.P, gEnv.mLights[i] );
       
       // If no in shadow 
       if( in_shadow( shadow_ray, gEnv.mLights[i] ) == false ) {
         float NL = abs( d( _objPt.N, shadow_ray.T ) );
         float Ilight[] = gEnv.mLights[i].mRGB;
         radiance[0] = radiance[0] + Ilight[0]*NL*diff[0];
         radiance[1] = radiance[1] + Ilight[1]*NL*diff[1];
         radiance[2] = radiance[2] + Ilight[2]*NL*diff[2];         
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
   ray ray_through_pixel( int _x, int _y ) {
     ray R = new ray();
     pt P = mE; /** Origin */

     pt Pi = new pt( mdx*( -mnx_2 + 0.5 + _x), mdy*( mny_2 - 0.5 - _y), -mf );
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
