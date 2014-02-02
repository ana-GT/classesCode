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
