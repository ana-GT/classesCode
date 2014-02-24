/**
 * @class naiveStack
 * @brief Simple stack for matrix transformations
 */
public class naiveStack {
  private int mSize = 0;
  private static final int MAX_CAPACITY = 20;
  private PMatrix3D mMats[];
  
  /** Constructor */
  public naiveStack() {
    mMats = new PMatrix3D[MAX_CAPACITY];
    for( int i = 0; i < MAX_CAPACITY;++i ) {
      mMats[i] = new PMatrix3D();
      mMats[i].reset();
    }
  }
  
  /**< Push */
  public void push( PMatrix3D mat ) {
    if( mSize == mMats.length ) {
      print("[DANGER] Oh, no! you are exceeding my capacity. I will do evil things to your code! \n");
      return;
    }   
    mMats[mSize].set( mat );
    mSize++;
  }
  
  /**< Pop */
  public PMatrix3D pop() {
    PMatrix3D mat = new PMatrix3D(); 
    mat.set( mMats[mSize - 1] );
    mMats[mSize-1].reset();
    mSize--;
      
    return mat;
  }
};


/**
 * @class objectStack
 * @brief Object stack for matrix transformations
 */
public class objectStack {
  private int mSize = 0;
  private static final int MAX_CAPACITY = 70000;
  private Primitive mPrims[];
  
  /** Constructor */
  public objectStack() {
    mPrims = new Primitive[MAX_CAPACITY];
    for( int i = 0; i < MAX_CAPACITY;++i ) {
      mPrims[i] = new Primitive();
    }
  }
  
  public int getSize() { return mSize; }
  
  /**< Push */
  public void push( Primitive _p ) {
    if( mSize == mPrims.length ) {
      print("[DANGER PushStack] Oh, no! you are exceeding my capacity. I will do evil things to your code! \n");
      return;
    }   
    
    if( _p.getType() == sTriangleType ) {
         mPrims[mSize] = new Triangle();
        ((Triangle)mPrims[mSize]).copyData( (Triangle)_p );  
    } else {
      print("objStack: PUSH: CHECK THE FUNCTION I AM NOT ADDING STUFF!!! \n");
    }
    mSize++;
  }
  
  /**< Pop */
  public Primitive pop() {
    Primitive p = new Primitive(); 
    if( mPrims[mSize - 1].getType() == sTriangleType ) {
      p = new Triangle();
      ((Triangle)p).copyData( (Triangle)mPrims[mSize - 1] );
    } else {
    }
    
    mSize--;
      
    return p;
  }
};
