/**
  * @class pt
 */
 
/** @class objPt */
class objPt {
  public int objIndex;
  public vec N;
  public pt P;
  
  objPt() { objIndex = -1; P = new pt(0,0,0); }
  void set( int _objIndex, pt _P ) { objIndex = _objIndex; P = _P; }
  
  boolean is_set() { 
    if( objIndex == -1 ) { return false; } 
    else {return true; } 
  }
  
}; 


/**
 * @class ray
 */
class ray {
  private pt P = new pt();
  private vec T = new vec();
  
  ray() {};
  ray set( pt _P, vec _T ) { 
    P = new pt(_P.x, _P.y, _P.z); 
    T = _T; return this;
  }
  
  pt P() { return P; }
  vec T() { return T; }
};


// Geometry tools I used on my class in  Fall 2012 - CS 4640 (Computer Graphics)
// A bunch of these are based on the Geometry tools file from **Prof. Jarek Rossignac**, which were provided for us to customize to make things easier.
// I do not use any rendering function from here. Only functions such as
// .dot, .mult and vector / points operations were used. 
// PS.- I suppose I could just copied and pasted taking out the author's name, but
// that would be misleading. Hope it is okay.

/**< Class vec */
class vec { float x=0,y=0,z=0; 
   vec () {}; 
   vec (float px, float py, float pz) {x = px; y = py; z = pz;};
   vec set (float px, float py, float pz) {x = px; y = py; z = pz; return this;}; 
   vec set (vec V) {x = V.x; y = V.y; z = V.z; return this;}; 
   vec add(vec V) {x+=V.x; y+=V.y; z+=V.z; return this;};
   vec add(float s, vec V) {x+=s*V.x; y+=s*V.y; z+=s*V.z; return this;};
   vec sub(vec V) {x-=V.x; y-=V.y; z-=V.z; return this;};
   vec mul(float f) {x*=f; y*=f; z*=f; return this;};
   vec div(float f) {x/=f; y/=f; z/=f; return this;};
   vec div(int f) {x/=f; y/=f; z/=f; return this;};
   vec rev() {x=-x; y=-y; z=-z; return this;};
   float norm() {return(sqrt(sq(x)+sq(y)+sq(z)));}; 
   vec normalize() {float n=norm(); if (n>0.000001) {div(n);}; return this;};
   vec rotate(float a, vec I, vec J) {float x=d(this,I), y=d(this,J); float c=cos(a), s=sin(a); add(x*c-x-y*s,I); add(x*s+y*c-y,J); return this; }; // Rotate by a in plane (I,J)
   } ;
  
/**< Vector functions */
vec V() {return new vec(); };                                                                          // make vector (x,y,z)
vec V(float x, float y, float z) {return new vec(x,y,z); };                                            // make vector (x,y,z)
vec V(vec V) {return new vec(V.x,V.y,V.z); };                                                          // make copy of vector V
vec A(vec A, vec B) {return new vec(A.x+B.x,A.y+B.y,A.z+B.z); };                                       // A+B
vec A(vec U, float s, vec V) {return V(U.x+s*V.x,U.y+s*V.y,U.z+s*V.z);};                               // U+sV
vec M(vec U, vec V) {return V(U.x-V.x,U.y-V.y,U.z-V.z);};                                              // U-V
vec M(vec V) {return V(-V.x,-V.y,-V.z);};                                                              // -V
vec V(vec A, vec B) {return new vec((A.x+B.x)/2.0,(A.y+B.y)/2.0,(A.z+B.z)/2.0); }                      // (A+B)/2
vec V(vec A, float s, vec B) {return new vec(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y),A.z+s*(B.z-A.z)); };      // (1-s)A+sB
vec V(vec A, vec B, vec C) {return new vec((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0,(A.z+B.z+C.z)/3.0); };  // (A+B+C)/3
vec V(vec A, vec B, vec C, vec D) {return V(V(A,B),V(C,D)); };                                         // (A+B+C+D)/4
vec V(float s, vec A) {return new vec(s*A.x,s*A.y,s*A.z); };                                           // sA
vec V(float a, vec A, float b, vec B) {return A(V(a,A),V(b,B));}                                       // aA+bB 
vec V(float a, vec A, float b, vec B, float c, vec C) {return A(V(a,A,b,B),V(c,C));}                   // aA+bB+cC
vec V(pt P, pt Q) {return new vec(Q.x-P.x,Q.y-P.y,Q.z-P.z);};                                          // PQ
vec U(vec V) {float n = V.norm(); if (n<0.000001) return V(0,0,0); else return V(1./n,V);};            // V/||V||
vec U(pt A, pt B) {return U(V(A,B));}
vec N(vec U, vec V) {return V( U.y*V.z-U.z*V.y, U.z*V.x-U.x*V.z, U.x*V.y-U.y*V.x); };                  // UxV CROSS PRODUCT (normal to both)
vec N(pt A, pt B, pt C) {return N(V(A,B),V(A,C)); };                                                   // normal to triangle (A,B,C), not normalized (proportional to area)
vec B(vec U, vec V) {return U(N(N(U,V),U)); }                                                           // (UxV)xV unit normal to U in the plane UV
vec R(vec V) {return V(-V.y,V.x,V.z);} // rotated 90 degrees in XY plane
vec R(vec V, float a, vec I, vec J) {float x=d(V,I), y=d(V,J); float c=cos(a), s=sin(a); return A(V,V(x*c-x-y*s,I,x*s+y*c-y,J)); }; // Rotated V by a parallel to plane (I,J)


/**< Point class */
class pt { float x=0,y=0,z=0; 
   pt () {}; 
   pt (float px, float py, float pz) {x = px; y = py; z = pz; };
   pt set (float px, float py, float pz) {x = px; y = py; z = pz; return this;}; 
   pt set (pt P) {x = P.x; y = P.y; z = P.z; return this;}; 
   pt add(pt P) {x+=P.x; y+=P.y; z+=P.z; return this;};
   pt add(vec V) {x+=V.x; y+=V.y; z+=V.z; return this;};
   pt add(float s, vec V) {x+=s*V.x; y+=s*V.y; z+=s*V.z; return this;};
   pt add(float dx, float dy, float dz) {x+=dx; y+=dy; z+=dz; return this;};
   pt sub(pt P) {x-=P.x; y-=P.y; z-=P.z; return this;};
   pt mul(float f) {x*=f; y*=f; z*=f; return this;};
   pt mul(float dx, float dy, float dz) {x*=dx; y*=dy; z*=dz; return this;};
   pt div(float f) {x/=f; y/=f; z/=f; return this;};
   pt div(int f) {x/=f; y/=f; z/=f; return this;};
   pt snap(float r) {float f=r/(sqrt(sq(x)+sq(y)+sq(z))); x*=f; y*=f; z*=f; return this;};
   }
 
/**  point functions */
pt P() {return new pt(); };                                            // point (x,y,z)
pt P(float x, float y, float z) {return new pt(x,y,z); };                                            // point (x,y,z)
pt P(pt A) {return new pt(A.x,A.y,A.z); };                                                           // copy of point P
pt P(pt A, float s, pt B) {return new pt(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y),A.z+s*(B.z-A.z)); };        // A+sAB
pt P(pt A, pt B) {return P((A.x+B.x)/2.0,(A.y+B.y)/2.0,(A.z+B.z)/2.0); }                             // (A+B)/2
pt P(pt A, pt B, pt C) {return new pt((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0,(A.z+B.z+C.z)/3.0); };     // (A+B+C)/3
pt P(pt A, pt B, pt C, pt D) {return P(P(A,B),P(C,D)); };                                            // (A+B+C+D)/4
pt P(float s, pt A) {return new pt(s*A.x,s*A.y,s*A.z); };                                            // sA
pt A(pt A, pt B) {return new pt(A.x+B.x,A.y+B.y,A.z+B.z); };                                         // A+B
pt P(float a, pt A, float b, pt B) {return A(P(a,A),P(b,B));}                                        // aA+bB 
pt P(float a, pt A, float b, pt B, float c, pt C) {return A(P(a,A),P(b,B,c,C));}                     // aA+bB+cC 
pt P(float a, pt A, float b, pt B, float c, pt C, float d, pt D){return A(P(a,A,b,B),P(c,C,d,D));}   // aA+bB+cC+dD
pt P(pt P, vec V) {return new pt(P.x + V.x, P.y + V.y, P.z + V.z); }                                 // P+V
pt P(pt P, float s, vec V) {return new pt(P.x+s*V.x,P.y+s*V.y,P.z+s*V.z);}                           // P+sV
pt P(pt O, float x, vec I, float y, vec J) {return P(O.x+x*I.x+y*J.x,O.y+x*I.y+y*J.y,O.z+x*I.z+y*J.z);}  // O+xI+yJ
pt P(pt O, float x, vec I, float y, vec J, float z, vec K) {return P(O.x+x*I.x+y*J.x+z*K.x,O.y+x*I.y+y*J.y+z*K.y,O.z+x*I.z+y*J.z+z*K.z);}  // O+xI+yJ+kZ
pt R(pt P, float a, vec I, vec J, pt G) {float x=d(V(G,P),I), y=d(V(G,P),J); float c=cos(a), s=sin(a); return P(P,x*c-x-y*s,I,x*s+y*c-y,J); }; // Rotated P by a around G in plane (I,J)
void makePts(pt[] C) {for(int i=0; i<C.length; i++) C[i]=P();} // fills array C with points initialized to (0,0,0)
pt Predict(pt A, pt B, pt C) {return P(B,V(A,C)); };     // B+AC, parallelogram predictor
void v(pt P) {vertex(P.x,P.y,P.z);} // rendering

/**< Measurements */
float d(vec U, vec V) {return U.x*V.x+U.y*V.y+U.z*V.z; }; //U*V dot product
float d(pt P, pt Q) {return sqrt(sq(Q.x-P.x)+sq(Q.y-P.y)+sq(Q.z-P.z)); }; // ||AB|| distance
