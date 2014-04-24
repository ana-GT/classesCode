// Classic Perlin noise, 3D version
import java.util.Random;
import java.util.List;
import java.util.ArrayList;

/**
 * @function stone_color
 * @brief 
 */
float[] stone_color( float[] D, float _x, float _y, float _z ) {

  // Cement
 float [] c1 = new float[3]; c1[0] = 0.75; c1[1] = 0.75; c1[2] = 0.75;
 // Tile
 float [] c2 = new float[3]; c2[0] = 0.82; c2[1] = 0.41; c2[2] = 0.12  ;  
 //float [] c2 = new float[3]; c2[0] = 250.0 / 255.0; c2[1] = 128.0/255.0; c2[2] = 114.0/255.0  ;  
 

  float []c = new float[3];
     
  float crack_thresh = 0.03;
  float noise = D[1] - D[0];
     if( noise < crack_thresh && noise > -1*crack_thresh ) {
       float f = 60.0;
       float n = noise_3d( f*_x, f*_y, f*_z )*0.5 + 0.5;
       n = 0.25 + 0.75*n; // Default no less than 25% of original color
       
       c[0] = c1[0]*n;
       c[1] = c1[1]*n;
       c[2] = c1[2]*n;     
       return c;      
     }
     
     else {
       Random rand = new Random( (int)D[2] );
       c[0] = c2[0]*rand.nextFloat();
       c[1] = c2[1]*rand.nextFloat();
       c[2] = c2[2]*rand.nextFloat();     
       return c;
     }
} 
     
/**
 * @function wood_color
 * @brief INPUT SHOULD BE BETWEEN 0 and 1
 */
float[] wood_color( float n ) {
  
  float []c = new float[3];
  
  // Light Wood
 float [] c1 = new float[3]; c1[0] = 0.54; c1[1] = 0.27; c1[2] = 0.07;
 // Dark Wood 
 float [] c2 = new float[3]; c2[0] = 0.82; c2[1] = 0.41; c2[2] = 0.12  ;
 float [] dc = new float[3]; for( int i = 0; i < 3; ++i ) { dc[i] = c2[i] - c1[i]; }

 float grain = n % 0.09;
  
  if( grain > 0.05 ) { return c1; }
  else{ return c2; }

}

/**
 * @function marble_color
 */
float[] marble_color( float n ) {
  
  float []c = new float[3];
  
 float [] c1 = new float[3]; c1[0] = 0.1; c1[1] = 0.1; c1[2] = 0.0;
 float [] c2 = new float[3]; c2[0] = 0.9; c2[1] = 0.6; c2[2] = 0.6;
 float [] dc = new float[3]; for( int i = 0; i < 3; ++i ) { dc[i] = c2[i] - c1[i]; }

  float f = sqrt( n + 1.0 )*0.7071;
  c[1] = c1[1] + dc[1]*f;
  f = sqrt(f);
  c[0] = c1[0] + dc[0]*f;
  c[2] = c1[2] + dc[2]*f;  
 
  return c;
}

/**
 * @function turbulence
 * @brief From Siggraph 92, notes of course 23
 */
float turbulence( float x, float y, float z ) {

  float noise = 0;
  float nx = x + 123.456;
  float ny = y; float nz = z;
  
  float minF = 1.0;
  float maxF = 600;
  float f;
  
  for( f = minF; f < maxF; f = f*2.0 ) {
    noise = noise + (1.0/f)*abs( noise_3d(nx, ny, nz) );
    nx = nx*2.0;
    ny = ny*2.0;
    nz = nz*2.0;    
  }
  
  return noise - 0.3;
}

float noise_3d(float x, float y, float z) {
  
  // make sure we've initilized table
  if (init_flag == false) {
    initialize_table();
    init_flag = true;
  }
  
  // Find unit grid cell containing point
  int X = fastfloor(x);
  int Y = fastfloor(y);
  int Z = fastfloor(z);
  
  // Get relative xyz coordinates of point within that cell
  x = x - X;
  y = y - Y;
  z = z - Z;
  
  // Wrap the integer cells at 255 (smaller integer period can be introduced here)
  X = X & 255;
  Y = Y & 255;
  Z = Z & 255;
  
  // Calculate a set of eight hashed gradient indices
  int gi000 = perm[X+perm[Y+perm[Z]]] % 12;
  int gi001 = perm[X+perm[Y+perm[Z+1]]] % 12;
  int gi010 = perm[X+perm[Y+1+perm[Z]]] % 12;
  int gi011 = perm[X+perm[Y+1+perm[Z+1]]] % 12;
  int gi100 = perm[X+1+perm[Y+perm[Z]]] % 12;
  int gi101 = perm[X+1+perm[Y+perm[Z+1]]] % 12;
  int gi110 = perm[X+1+perm[Y+1+perm[Z]]] % 12;
  int gi111 = perm[X+1+perm[Y+1+perm[Z+1]]] % 12;
  
  // The gradients of each corner are now:
  // g000 = grad3[gi000];
  // g001 = grad3[gi001];
  // g010 = grad3[gi010];
  // g011 = grad3[gi011];
  // g100 = grad3[gi100];
  // g101 = grad3[gi101];
  // g110 = grad3[gi110];
  // g111 = grad3[gi111];
  
  // Calculate noise contributions from each of the eight corners
  double n000= dot(grad3[gi000], x, y, z);
  double n100= dot(grad3[gi100], x-1, y, z);
  double n010= dot(grad3[gi010], x, y-1, z);
  double n110= dot(grad3[gi110], x-1, y-1, z);
  double n001= dot(grad3[gi001], x, y, z-1);
  double n101= dot(grad3[gi101], x-1, y, z-1);
  double n011= dot(grad3[gi011], x, y-1, z-1);
  double n111= dot(grad3[gi111], x-1, y-1, z-1);
  
  // Compute the fade curve value for each of x, y, z
  double u = fade(x);
  double v = fade(y);
  double w = fade(z);
  
  // Interpolate along x the contributions from each of the corners
  double nx00 = mix(n000, n100, u);
  double nx01 = mix(n001, n101, u);
  double nx10 = mix(n010, n110, u);
  double nx11 = mix(n011, n111, u);
  
  // Interpolate the four results along y
  double nxy0 = mix(nx00, nx10, v);
  double nxy1 = mix(nx01, nx11, v);
  
  // Interpolate the two last results along z
  float nxyz = (float) mix(nxy0, nxy1, w);
  
  return nxyz;
}

boolean init_flag = false;

int grad3[][] = {{1,1,0},{-1,1,0},{1,-1,0},{-1,-1,0},
{1,0,1},{-1,0,1},{1,0,-1},{-1,0,-1},
{0,1,1},{0,-1,1},{0,1,-1},{0,-1,-1}};

int p[] = {151,160,137,91,90,15,
131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180};

// To remove the need for index wrapping, double the permutation table length
int perm[] = new int[512];

void initialize_table() {
  for(int i=0; i<512; i++) perm[i]=p[i & 255];
}

// This method is a *lot* faster than using (int)Math.floor(x)
int fastfloor(double x) {
  return x>0 ? (int)x : (int)x-1;
}

double dot(int g[], double x, double y, double z) {
  return g[0]*x + g[1]*y + g[2]*z;
}

double mix(double a, double b, double t) {
  return (1-t)*a + t*b;
}

double fade(double t) {
  return t*t*t*(t*(t*6-15)+10);
}

/**
 * @class worley_noise
 */
class worley_noise {

  Random rand;
  
  /**< Constructor */  
  worley_noise() {
    rand = new Random();
  }
    
  /**< get_noise (distance to the nth-nearest feature */
  float[] get_noise( float _x, float _y, float _z ) {
        
    float[] dist = new float[6]; // D1, D2, IND, PX, PY, PZ (CLOSEST POINT)
    
    // 1. Get the cube where the point lives
    int x,y,z;
    x = floor(_x);
    y = floor(_y);
    z = floor(_z);
    
    
    for( int i = 0; i < 2; ++i ) { dist[i] = 0; }
    
    // Get distances inside the central voxel 
    ArrayList<Float> allDists = new ArrayList<Float>(); 
    ArrayList<Integer> allInds = new ArrayList<Integer>();     
    ArrayList<pt> allPts = new ArrayList<pt>();      
        
    for( int i = -1; i <= 1; ++i ) {
      for( int j = -1; j <=1; ++j ) {
        for( int k = -1; k <=1; ++k ) { 
          ArrayList<Float> dists2 = new ArrayList<Float>();          
          ArrayList<Integer> inds2 = new ArrayList<Integer>();
          ArrayList<pt> points = new ArrayList<pt>();          
          dists2  = getVoxelDists( x + i, y + j, z + k, 
                                  _x, _y, _z, inds2, points );
                                  
          // Store                        
          for( int m = 0; m < dists2.size(); ++m ) {
            allDists.add( dists2.get(m) );
            allInds.add( inds2.get(m) );
            allPts.add( points.get(m) );
          }                        
                                  
        }
      }
    }
  
    // Check the first smallest
    float MIN_DIST = 10000; int MIN_INDEX = 0; pt MIN_PT = new pt();
    float MIN2_DIST = 10000;
    float d; int ind; pt pi = new pt();
    for( int i = 0; i < allDists.size(); ++i ) {
      d = allDists.get(i);
      ind = allInds.get(i);
      pi = allPts.get(i);
      if( d < MIN_DIST ) { MIN_DIST = d;  MIN_INDEX = ind; MIN_PT = pi; }
    }
    
    // Check the second smallest
    for( int i = 0; i < allDists.size(); ++i ) {
      d = allDists.get(i);
      if( d > MIN_DIST && d < MIN2_DIST ) { MIN2_DIST = d; }
    }    
  
    // Store the first distance!
    dist[0] = sqrt(MIN_DIST);
    dist[1] = sqrt(MIN2_DIST);
    dist[2] = MIN_INDEX;
    
    dist[3] = MIN_PT.x;
    dist[4] = MIN_PT.y;
    dist[5] = MIN_PT.z;
    
    return dist;
  } 
  
  /**< checkVoxel */
  ArrayList<Float> getVoxelDists( int x, int y, int z, 
                                   float _x, float _y, float _z,
                                  ArrayList<Integer>inds2, ArrayList<pt> _pts ) {

    ArrayList<Float> dists2 = new ArrayList<Float>();
    int num_points;
    
    // Index of the cube is used to seed a random number generator  
    seedRandom( x, y, z );
    
   // Random number is then used for a number of feature points inside the cube 
   num_points = floor( lerp( 2, 10, rand.nextFloat() ) ); 
 
  // Random number generator is used again to find coordinates of those feature points
  for( int i = 0; i < num_points; ++i ) {
    
    float []fp = new float[3];
    fp[0] = x + rand.nextFloat();
    fp[1] = y + rand.nextFloat();
    fp[2] = z + rand.nextFloat();
    
    float dx = fp[0]-_x; float dy = fp[1]-_y; float dz = fp[2]-_z;
    float d2 = dx*dx + dy*dy + dz*dz;
    
    dists2.add( d2 );
    inds2.add( i );
    _pts.add( new pt( fp[0], fp[1], fp[2]) );
  }

    return dists2;
}



  /**< Set seed */
  void seedRandom( int x, int y, int z ) {
    long seed = x* 65536 + y*256 + z;
    rand.setSeed( seed );
  }
  

  
  
};



