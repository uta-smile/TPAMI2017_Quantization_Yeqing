#include "mex.h" // Required for the use of MEX files


/*
// MatLab type eference:
typedef enum {
        mxUNKNOWN_CLASS,
        mxCELL_CLASS,
        mxSTRUCT_CLASS,
        mxLOGICAL_CLASS,
        mxCHAR_CLASS,
        mxVOID_CLASS,
        mxDOUBLE_CLASS,
        mxSINGLE_CLASS,
        mxINT8_CLASS,
        mxUINT8_CLASS,
        mxINT16_CLASS,
        mxUINT16_CLASS,
        mxINT32_CLASS,
        mxUINT32_CLASS,
        mxINT64_CLASS,
        mxUINT64_CLASS,
        mxFUNCTION_CLASS
} mxClassID;*/

#define SIGN(x) (((x)<0) ? -1:1)

template<typename T>
void compSign(T* input, T* result, int nrs, int ncs)
{
	int i,j;
    for(i = 0; i < nrs; i++)
	{
		for(j = 0; j < ncs; j++)
		{
			*result = SIGN(*input);
			result++; input++;
		}
	}
}

/** This is a the only prototype function that you need to get a mex file to work. */
void mexFunction(int output_size, mxArray *output[], int input_size, const mxArray *input[])
{
    mxArray *xData; 
    int ncs;
	int	nrs;
    /* check for proper number of arguments */
    if(input_size!=1) 
		mexErrMsgTxt("Usage: sign (<matrix>)");  
    //Copy input pointer 
    // This carries the input grayscale image that was sent from Matlab
    xData = (mxArray *)input[0];
    //Get the matrix from the input data
    // The matrix is rasterized in a column wise read
    //xValues =  mxGetPr(xData);
	nrs = mxGetM(xData); // Gives the number of Rows in the image  
    ncs = mxGetN(xData); // Gives the number of Columns in the image
	mxClassID inputType =  mxGetClassID(xData);
	if (inputType == mxDOUBLE_CLASS) {
		//output[0] = mxCreateDoubleMatrix(nrs, ncs, mxREAL);
		double *xValues = (double*) mxGetData(xData);
		output[0] = mxCreateNumericMatrix(nrs, ncs, mxDOUBLE_CLASS, mxREAL);
		double *result = (double*) mxGetData(output[0]);
		compSign(xValues, result, nrs, ncs);
	} else if (inputType == mxSINGLE_CLASS) {
		float *xValues = (float*) mxGetData(xData);
		output[0] = mxCreateNumericMatrix(nrs, ncs, mxSINGLE_CLASS, mxREAL);
		float *result = (float*) mxGetData(output[0]);
		compSign(xValues, result, nrs, ncs);
	} else {
		mexErrMsgTxt("Not support data type");
	}
	
    return;
}

