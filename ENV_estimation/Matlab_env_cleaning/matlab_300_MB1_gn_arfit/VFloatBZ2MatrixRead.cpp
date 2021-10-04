// outFea = VFloatBZ2MatrixRead( '/speech6/factor1/jwpeleca/CREATE_NIST_2008_FEATURES/MFCC_38_FEATURES/DEVELOPMENT/D08_f_44390/20070509_153028_LDC_44390_CH13.fea.bz2' );


// A MEX file for Matlab to enable the loading of VFloat files that are compressed using bzip2
#include <math.h>
#include "mex.h"
#include <cstdio>
#include <cmath>
#include <iostream>
#include <fstream>
#include <string>

/* Input Arguments */
#define FILENAME_IN    prhs[0]

/* Output Arguments */
#define FEATURES_OUT   plhs[0]

using namespace std;


#if !defined(MAX)
#define MAX(A, B)       ((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define MIN(A, B)       ((A) < (B) ? (A) : (B))
#endif



static void VFloatBZ2MatrixRead( char* filename, float*** speech_vectors, int* num_rows, int* num_cols )
{
   int i, j;
   int m_dims, m_num_vectors;
   int classID;
   int int_filler;
   float float_filler;

   float** m_speech_vectors;

   FILE *vector_file = NULL;

   vector_file = NULL;
   vector_file = fopen( filename, "r" );
   if( vector_file == NULL ) {
      speech_vectors = NULL;
      cerr << "ERROR: Could not open bzip2 vector file <" << filename << ">" << endl;
      return;
   }
   fclose( vector_file );

   // Attempt to open the file again but now a gzipped file 
   // (assumes this file already has the .bz2 extension)
   string bzip2_file = "bunzip2 -c " + (string)filename;
   vector_file = NULL;
   vector_file = popen( (const char * ) bzip2_file.c_str(), "r" );

   if( vector_file == NULL ) {
      speech_vectors = NULL;
      cerr << "ERROR: Could not open vector file <" << filename << ".bz2>" << endl;
      return;
   }

   // Determine the number of vectors and features
   fread( &m_num_vectors, sizeof(m_num_vectors), 1, vector_file ); 
   fread( &m_dims, sizeof(m_dims), 1, vector_file );  
 
   // Allocate memory for everything else
   m_speech_vectors = new float*[m_num_vectors];
   for( i=0; i < m_num_vectors; i++ )
      m_speech_vectors[i] = new float[m_dims];

   // Load in the vectors
   for( i=0; i < m_num_vectors; i++ ) {
      if( i != 0 )
         fread( &int_filler, sizeof( int_filler ), 1, vector_file );

      for( j=0; j < m_dims; j++ ) {
         fread( &float_filler, sizeof( float_filler ), 1, vector_file );
         m_speech_vectors[i][j] = float_filler;
      }
   }
 
   (*num_rows) = m_num_vectors;
   (*num_cols) = m_dims;
   (*speech_vectors) = m_speech_vectors;

   // Close the feature file
   pclose( vector_file );

   return;
}


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    char *input_buf;
    mwSize buflen;

    /* Check for proper number of arguments */
    
    if (nrhs != 1) { 
	mexErrMsgTxt("Only one input arguments required."); 
    } else if (nlhs > 1) {
	mexErrMsgTxt("Too many output arguments."); 
    } 
    
    /* input must be a string */
    if ( mxIsChar(FILENAME_IN) != 1)
      mexErrMsgTxt("Input must be a string.");

    /* input must be a row vector */
    if (mxGetM(FILENAME_IN)!=1)
      mexErrMsgTxt("Input must be a row vector.");
    
    /* get the length of the input string */
    buflen = (mxGetM(FILENAME_IN) * mxGetN(FILENAME_IN)) + 1;

    /* copy the string data from prhs[0] into a C string input_ buf.    */
    input_buf = mxArrayToString(FILENAME_IN);

    // Call the required function
    float** speech_vectors;
    int num_rows, num_cols;
    VFloatBZ2MatrixRead( input_buf, &speech_vectors, &num_rows, &num_cols );

    if( speech_vectors == NULL ) {
       mexErrMsgTxt("Unable to open .bz2 file."); 
    }

    /* Create a matrix for the return argument */
    FEATURES_OUT = mxCreateNumericMatrix( num_rows, num_cols, mxSINGLE_CLASS, mxREAL );

    /* Assign pointers to the various parameters */ 
    //float* features = mxGetPr(FEATURES_OUT);
    float* features = (float*)mxGetData(FEATURES_OUT);

    // Copy the data across
    int offset = 0;
    for( int j = 0; j < num_cols; j++ ) {
       for( int i=0; i < num_rows; i++ ) {
          features[offset++] = speech_vectors[i][j];  
       }
    }
    
    // Delete the previously allocated speech_vectors memory
    for( int i=0; i < num_rows; i++ )
       delete [] speech_vectors[i];

    delete [] speech_vectors;
   
    return;
    
}


