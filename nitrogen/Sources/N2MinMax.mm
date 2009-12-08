//
//  N2MinMax.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 11.11.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "N2MinMax.h"
#include <algorithm>

const CGFloat N2NoMin = CGFLOAT_MIN, N2NoMax = CGFLOAT_MAX;

N2MinMax N2MakeMinMax(CGFloat min, CGFloat max) {
	N2MinMax mm = {min, max};
	return mm;
}

N2MinMax N2MakeMinMax(CGFloat val) {
	return N2MakeMinMax(val, val);
}

N2MinMax N2MakeMinMax() {
	return N2MakeMinMax(N2NoMin, N2NoMax);
}

N2MinMax N2MakeMin(CGFloat min) {
	return N2MakeMinMax(min, N2NoMax);
}

N2MinMax N2MakeMax(CGFloat max) {
	return N2MakeMinMax(N2NoMin, max);
}

CGFloat N2MinMaxConstrainedValue(const N2MinMax& mm, CGFloat val) {
	if (val < mm.min) val = mm.min;
	if (val > mm.max) val = mm.max;
	return val;
}

void N2ExtendMinMax(N2MinMax& n2minmax, CGFloat value) {
	n2minmax.min = std::min(n2minmax.min, value);
	n2minmax.max = std::max(n2minmax.max, value);
}