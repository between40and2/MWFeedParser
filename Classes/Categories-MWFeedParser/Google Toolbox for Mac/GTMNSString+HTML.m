//
//  GTMNSString+HTML.m
//  Dealing with NSStrings that contain HTML
//
//  Copyright 2006-2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

//#import "GTMDefines.h"
#import "GTMNSString+HTML.h"

typedef struct {
	CFStringRef escapeSequence;
	unichar uchar;
} HTMLEscapeMap;

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// Ordered by uchar lowest to highest for bsearching
static HTMLEscapeMap gAsciiHTMLEscapeMap[] = {
	// A.2.2. Special characters
	{ (__block CFStringRef) @"&quot;", 34 },
	{ (__block CFStringRef) @"&amp;", 38 },
	{ (__block CFStringRef) @"&apos;", 39 },
	{ (__block CFStringRef) @"&lt;", 60 },
	{ (__block CFStringRef) @"&gt;", 62 },
	
    // A.2.1. Latin-1 characters
	{ (__block CFStringRef) @"&nbsp;", 160 }, 
	{ (__block CFStringRef) @"&iexcl;", 161 }, 
	{ (__block CFStringRef) @"&cent;", 162 }, 
	{ (__block CFStringRef) @"&pound;", 163 }, 
	{ (__block CFStringRef) @"&curren;", 164 }, 
	{ (__block CFStringRef) @"&yen;", 165 }, 
	{ (__block CFStringRef) @"&brvbar;", 166 }, 
	{ (__block CFStringRef) @"&sect;", 167 }, 
	{ (__block CFStringRef) @"&uml;", 168 }, 
	{ (__block CFStringRef) @"&copy;", 169 }, 
	{ (__block CFStringRef) @"&ordf;", 170 }, 
	{ (__block CFStringRef) @"&laquo;", 171 }, 
	{ (__block CFStringRef) @"&not;", 172 }, 
	{ (__block CFStringRef) @"&shy;", 173 }, 
	{ (__block CFStringRef) @"&reg;", 174 }, 
	{ (__block CFStringRef) @"&macr;", 175 }, 
	{ (__block CFStringRef) @"&deg;", 176 }, 
	{ (__block CFStringRef) @"&plusmn;", 177 }, 
	{ (__block CFStringRef) @"&sup2;", 178 }, 
	{ (__block CFStringRef) @"&sup3;", 179 }, 
	{ (__block CFStringRef) @"&acute;", 180 }, 
	{ (__block CFStringRef) @"&micro;", 181 }, 
	{ (__block CFStringRef) @"&para;", 182 }, 
	{ (__block CFStringRef) @"&middot;", 183 }, 
	{ (__block CFStringRef) @"&cedil;", 184 }, 
	{ (__block CFStringRef) @"&sup1;", 185 }, 
	{ (__block CFStringRef) @"&ordm;", 186 }, 
	{ (__block CFStringRef) @"&raquo;", 187 }, 
	{ (__block CFStringRef) @"&frac14;", 188 }, 
	{ (__block CFStringRef) @"&frac12;", 189 }, 
	{ (__block CFStringRef) @"&frac34;", 190 }, 
	{ (__block CFStringRef) @"&iquest;", 191 }, 
	{ (__block CFStringRef) @"&Agrave;", 192 }, 
	{ (__block CFStringRef) @"&Aacute;", 193 }, 
	{ (__block CFStringRef) @"&Acirc;", 194 }, 
	{ (__block CFStringRef) @"&Atilde;", 195 }, 
	{ (__block CFStringRef) @"&Auml;", 196 }, 
	{ (__block CFStringRef) @"&Aring;", 197 }, 
	{ (__block CFStringRef) @"&AElig;", 198 }, 
	{ (__block CFStringRef) @"&Ccedil;", 199 }, 
	{ (__block CFStringRef) @"&Egrave;", 200 }, 
	{ (__block CFStringRef) @"&Eacute;", 201 }, 
	{ (__block CFStringRef) @"&Ecirc;", 202 }, 
	{ (__block CFStringRef) @"&Euml;", 203 }, 
	{ (__block CFStringRef) @"&Igrave;", 204 }, 
	{ (__block CFStringRef) @"&Iacute;", 205 }, 
	{ (__block CFStringRef) @"&Icirc;", 206 }, 
	{ (__block CFStringRef) @"&Iuml;", 207 }, 
	{ (__block CFStringRef) @"&ETH;", 208 }, 
	{ (__block CFStringRef) @"&Ntilde;", 209 }, 
	{ (__block CFStringRef) @"&Ograve;", 210 }, 
	{ (__block CFStringRef) @"&Oacute;", 211 }, 
	{ (__block CFStringRef) @"&Ocirc;", 212 }, 
	{ (__block CFStringRef) @"&Otilde;", 213 }, 
	{ (__block CFStringRef) @"&Ouml;", 214 }, 
	{ (__block CFStringRef) @"&times;", 215 }, 
	{ (__block CFStringRef) @"&Oslash;", 216 }, 
	{ (__block CFStringRef) @"&Ugrave;", 217 }, 
	{ (__block CFStringRef) @"&Uacute;", 218 }, 
	{ (__block CFStringRef) @"&Ucirc;", 219 }, 
	{ (__block CFStringRef) @"&Uuml;", 220 }, 
	{ (__block CFStringRef) @"&Yacute;", 221 }, 
	{ (__block CFStringRef) @"&THORN;", 222 }, 
	{ (__block CFStringRef) @"&szlig;", 223 }, 
	{ (__block CFStringRef) @"&agrave;", 224 }, 
	{ (__block CFStringRef) @"&aacute;", 225 }, 
	{ (__block CFStringRef) @"&acirc;", 226 }, 
	{ (__block CFStringRef) @"&atilde;", 227 }, 
	{ (__block CFStringRef) @"&auml;", 228 }, 
	{ (__block CFStringRef) @"&aring;", 229 }, 
	{ (__block CFStringRef) @"&aelig;", 230 }, 
	{ (__block CFStringRef) @"&ccedil;", 231 }, 
	{ (__block CFStringRef) @"&egrave;", 232 }, 
	{ (__block CFStringRef) @"&eacute;", 233 }, 
	{ (__block CFStringRef) @"&ecirc;", 234 }, 
	{ (__block CFStringRef) @"&euml;", 235 }, 
	{ (__block CFStringRef) @"&igrave;", 236 }, 
	{ (__block CFStringRef) @"&iacute;", 237 }, 
	{ (__block CFStringRef) @"&icirc;", 238 }, 
	{ (__block CFStringRef) @"&iuml;", 239 }, 
	{ (__block CFStringRef) @"&eth;", 240 }, 
	{ (__block CFStringRef) @"&ntilde;", 241 }, 
	{ (__block CFStringRef) @"&ograve;", 242 }, 
	{ (__block CFStringRef) @"&oacute;", 243 }, 
	{ (__block CFStringRef) @"&ocirc;", 244 }, 
	{ (__block CFStringRef) @"&otilde;", 245 }, 
	{ (__block CFStringRef) @"&ouml;", 246 }, 
	{ (__block CFStringRef) @"&divide;", 247 }, 
	{ (__block CFStringRef) @"&oslash;", 248 }, 
	{ (__block CFStringRef) @"&ugrave;", 249 }, 
	{ (__block CFStringRef) @"&uacute;", 250 }, 
	{ (__block CFStringRef) @"&ucirc;", 251 }, 
	{ (__block CFStringRef) @"&uuml;", 252 }, 
	{ (__block CFStringRef) @"&yacute;", 253 }, 
	{ (__block CFStringRef) @"&thorn;", 254 }, 
	{ (__block CFStringRef) @"&yuml;", 255 },
	
	// A.2.2. Special characters cont'd
	{ (__block CFStringRef) @"&OElig;", 338 },
	{ (__block CFStringRef) @"&oelig;", 339 },
	{ (__block CFStringRef) @"&Scaron;", 352 },
	{ (__block CFStringRef) @"&scaron;", 353 },
	{ (__block CFStringRef) @"&Yuml;", 376 },
	
	// A.2.3. Symbols
	{ (__block CFStringRef) @"&fnof;", 402 }, 
	
	// A.2.2. Special characters cont'd
	{ (__block CFStringRef) @"&circ;", 710 },
	{ (__block CFStringRef) @"&tilde;", 732 },
	
	// A.2.3. Symbols cont'd
	{ (__block CFStringRef) @"&Alpha;", 913 }, 
	{ (__block CFStringRef) @"&Beta;", 914 }, 
	{ (__block CFStringRef) @"&Gamma;", 915 }, 
	{ (__block CFStringRef) @"&Delta;", 916 }, 
	{ (__block CFStringRef) @"&Epsilon;", 917 }, 
	{ (__block CFStringRef) @"&Zeta;", 918 }, 
	{ (__block CFStringRef) @"&Eta;", 919 }, 
	{ (__block CFStringRef) @"&Theta;", 920 }, 
	{ (__block CFStringRef) @"&Iota;", 921 }, 
	{ (__block CFStringRef) @"&Kappa;", 922 }, 
	{ (__block CFStringRef) @"&Lambda;", 923 }, 
	{ (__block CFStringRef) @"&Mu;", 924 }, 
	{ (__block CFStringRef) @"&Nu;", 925 }, 
	{ (__block CFStringRef) @"&Xi;", 926 }, 
	{ (__block CFStringRef) @"&Omicron;", 927 }, 
	{ (__block CFStringRef) @"&Pi;", 928 }, 
	{ (__block CFStringRef) @"&Rho;", 929 }, 
	{ (__block CFStringRef) @"&Sigma;", 931 }, 
	{ (__block CFStringRef) @"&Tau;", 932 }, 
	{ (__block CFStringRef) @"&Upsilon;", 933 }, 
	{ (__block CFStringRef) @"&Phi;", 934 }, 
	{ (__block CFStringRef) @"&Chi;", 935 }, 
	{ (__block CFStringRef) @"&Psi;", 936 }, 
	{ (__block CFStringRef) @"&Omega;", 937 }, 
	{ (__block CFStringRef) @"&alpha;", 945 }, 
	{ (__block CFStringRef) @"&beta;", 946 }, 
	{ (__block CFStringRef) @"&gamma;", 947 }, 
	{ (__block CFStringRef) @"&delta;", 948 }, 
	{ (__block CFStringRef) @"&epsilon;", 949 }, 
	{ (__block CFStringRef) @"&zeta;", 950 }, 
	{ (__block CFStringRef) @"&eta;", 951 }, 
	{ (__block CFStringRef) @"&theta;", 952 }, 
	{ (__block CFStringRef) @"&iota;", 953 }, 
	{ (__block CFStringRef) @"&kappa;", 954 }, 
	{ (__block CFStringRef) @"&lambda;", 955 }, 
	{ (__block CFStringRef) @"&mu;", 956 }, 
	{ (__block CFStringRef) @"&nu;", 957 }, 
	{ (__block CFStringRef) @"&xi;", 958 }, 
	{ (__block CFStringRef) @"&omicron;", 959 }, 
	{ (__block CFStringRef) @"&pi;", 960 }, 
	{ (__block CFStringRef) @"&rho;", 961 }, 
	{ (__block CFStringRef) @"&sigmaf;", 962 }, 
	{ (__block CFStringRef) @"&sigma;", 963 }, 
	{ (__block CFStringRef) @"&tau;", 964 }, 
	{ (__block CFStringRef) @"&upsilon;", 965 }, 
	{ (__block CFStringRef) @"&phi;", 966 }, 
	{ (__block CFStringRef) @"&chi;", 967 }, 
	{ (__block CFStringRef) @"&psi;", 968 }, 
	{ (__block CFStringRef) @"&omega;", 969 }, 
	{ (__block CFStringRef) @"&thetasym;", 977 }, 
	{ (__block CFStringRef) @"&upsih;", 978 }, 
	{ (__block CFStringRef) @"&piv;", 982 }, 
	
	// A.2.2. Special characters cont'd
	{ (__block CFStringRef) @"&ensp;", 8194 },
	{ (__block CFStringRef) @"&emsp;", 8195 },
	{ (__block CFStringRef) @"&thinsp;", 8201 },
	{ (__block CFStringRef) @"&zwnj;", 8204 },
	{ (__block CFStringRef) @"&zwj;", 8205 },
	{ (__block CFStringRef) @"&lrm;", 8206 },
	{ (__block CFStringRef) @"&rlm;", 8207 },
	{ (__block CFStringRef) @"&ndash;", 8211 },
	{ (__block CFStringRef) @"&mdash;", 8212 },
	{ (__block CFStringRef) @"&lsquo;", 8216 },
	{ (__block CFStringRef) @"&rsquo;", 8217 },
	{ (__block CFStringRef) @"&sbquo;", 8218 },
	{ (__block CFStringRef) @"&ldquo;", 8220 },
	{ (__block CFStringRef) @"&rdquo;", 8221 },
	{ (__block CFStringRef) @"&bdquo;", 8222 },
	{ (__block CFStringRef) @"&dagger;", 8224 },
	{ (__block CFStringRef) @"&Dagger;", 8225 },
    // A.2.3. Symbols cont'd  
	{ (__block CFStringRef) @"&bull;", 8226 }, 
	{ (__block CFStringRef) @"&hellip;", 8230 }, 
	
	// A.2.2. Special characters cont'd
	{ (__block CFStringRef) @"&permil;", 8240 },
	
	// A.2.3. Symbols cont'd  
	{ (__block CFStringRef) @"&prime;", 8242 }, 
	{ (__block CFStringRef) @"&Prime;", 8243 }, 
	
	// A.2.2. Special characters cont'd
	{ (__block CFStringRef) @"&lsaquo;", 8249 },
	{ (__block CFStringRef) @"&rsaquo;", 8250 },
	
	// A.2.3. Symbols cont'd  
	{ (__block CFStringRef) @"&oline;", 8254 }, 
	{ (__block CFStringRef) @"&frasl;", 8260 }, 
	
	// A.2.2. Special characters cont'd
	{ (__block CFStringRef) @"&euro;", 8364 },
	
	// A.2.3. Symbols cont'd  
	{ (__block CFStringRef) @"&image;", 8465 },
	{ (__block CFStringRef) @"&weierp;", 8472 }, 
	{ (__block CFStringRef) @"&real;", 8476 }, 
	{ (__block CFStringRef) @"&trade;", 8482 }, 
	{ (__block CFStringRef) @"&alefsym;", 8501 }, 
	{ (__block CFStringRef) @"&larr;", 8592 }, 
	{ (__block CFStringRef) @"&uarr;", 8593 }, 
	{ (__block CFStringRef) @"&rarr;", 8594 }, 
	{ (__block CFStringRef) @"&darr;", 8595 }, 
	{ (__block CFStringRef) @"&harr;", 8596 }, 
	{ (__block CFStringRef) @"&crarr;", 8629 }, 
	{ (__block CFStringRef) @"&lArr;", 8656 }, 
	{ (__block CFStringRef) @"&uArr;", 8657 }, 
	{ (__block CFStringRef) @"&rArr;", 8658 }, 
	{ (__block CFStringRef) @"&dArr;", 8659 }, 
	{ (__block CFStringRef) @"&hArr;", 8660 }, 
	{ (__block CFStringRef) @"&forall;", 8704 }, 
	{ (__block CFStringRef) @"&part;", 8706 }, 
	{ (__block CFStringRef) @"&exist;", 8707 }, 
	{ (__block CFStringRef) @"&empty;", 8709 }, 
	{ (__block CFStringRef) @"&nabla;", 8711 }, 
	{ (__block CFStringRef) @"&isin;", 8712 }, 
	{ (__block CFStringRef) @"&notin;", 8713 }, 
	{ (__block CFStringRef) @"&ni;", 8715 }, 
	{ (__block CFStringRef) @"&prod;", 8719 }, 
	{ (__block CFStringRef) @"&sum;", 8721 }, 
	{ (__block CFStringRef) @"&minus;", 8722 }, 
	{ (__block CFStringRef) @"&lowast;", 8727 }, 
	{ (__block CFStringRef) @"&radic;", 8730 }, 
	{ (__block CFStringRef) @"&prop;", 8733 }, 
	{ (__block CFStringRef) @"&infin;", 8734 }, 
	{ (__block CFStringRef) @"&ang;", 8736 }, 
	{ (__block CFStringRef) @"&and;", 8743 }, 
	{ (__block CFStringRef) @"&or;", 8744 }, 
	{ (__block CFStringRef) @"&cap;", 8745 }, 
	{ (__block CFStringRef) @"&cup;", 8746 }, 
	{ (__block CFStringRef) @"&int;", 8747 }, 
	{ (__block CFStringRef) @"&there4;", 8756 }, 
	{ (__block CFStringRef) @"&sim;", 8764 }, 
	{ (__block CFStringRef) @"&cong;", 8773 }, 
	{ (__block CFStringRef) @"&asymp;", 8776 }, 
	{ (__block CFStringRef) @"&ne;", 8800 }, 
	{ (__block CFStringRef) @"&equiv;", 8801 }, 
	{ (__block CFStringRef) @"&le;", 8804 }, 
	{ (__block CFStringRef) @"&ge;", 8805 }, 
	{ (__block CFStringRef) @"&sub;", 8834 }, 
	{ (__block CFStringRef) @"&sup;", 8835 }, 
	{ (__block CFStringRef) @"&nsub;", 8836 }, 
	{ (__block CFStringRef) @"&sube;", 8838 }, 
	{ (__block CFStringRef) @"&supe;", 8839 }, 
	{ (__block CFStringRef) @"&oplus;", 8853 }, 
	{ (__block CFStringRef) @"&otimes;", 8855 }, 
	{ (__block CFStringRef) @"&perp;", 8869 }, 
	{ (__block CFStringRef) @"&sdot;", 8901 }, 
	{ (__block CFStringRef) @"&lceil;", 8968 }, 
	{ (__block CFStringRef) @"&rceil;", 8969 }, 
	{ (__block CFStringRef) @"&lfloor;", 8970 }, 
	{ (__block CFStringRef) @"&rfloor;", 8971 }, 
	{ (__block CFStringRef) @"&lang;", 9001 }, 
	{ (__block CFStringRef) @"&rang;", 9002 }, 
	{ (__block CFStringRef) @"&loz;", 9674 }, 
	{ (__block CFStringRef) @"&spades;", 9824 }, 
	{ (__block CFStringRef) @"&clubs;", 9827 }, 
	{ (__block CFStringRef) @"&hearts;", 9829 }, 
	{ (__block CFStringRef) @"&diams;", 9830 }
};

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// This is table A.2.2 Special Characters
static HTMLEscapeMap gUnicodeHTMLEscapeMap[] = {
	// C0 Controls and Basic Latin
	{ (__block CFStringRef) @"&quot;", 34 },
	{ (__block CFStringRef) @"&amp;", 38 },
	{ (__block CFStringRef) @"&apos;", 39 },
	{ (__block CFStringRef) @"&lt;", 60 },
	{ (__block CFStringRef) @"&gt;", 62 },
	
	// Latin Extended-A
	{ (__block CFStringRef) @"&OElig;", 338 },
	{ (__block CFStringRef) @"&oelig;", 339 },
	{ (__block CFStringRef) @"&Scaron;", 352 },
	{ (__block CFStringRef) @"&scaron;", 353 },
	{ (__block CFStringRef) @"&Yuml;", 376 },
	
	// Spacing Modifier Letters
	{ (__block CFStringRef) @"&circ;", 710 },
	{ (__block CFStringRef) @"&tilde;", 732 },
    
	// General Punctuation
	{ (__block CFStringRef) @"&ensp;", 8194 },
	{ (__block CFStringRef) @"&emsp;", 8195 },
	{ (__block CFStringRef) @"&thinsp;", 8201 },
	{ (__block CFStringRef) @"&zwnj;", 8204 },
	{ (__block CFStringRef) @"&zwj;", 8205 },
	{ (__block CFStringRef) @"&lrm;", 8206 },
	{ (__block CFStringRef) @"&rlm;", 8207 },
	{ (__block CFStringRef) @"&ndash;", 8211 },
	{ (__block CFStringRef) @"&mdash;", 8212 },
	{ (__block CFStringRef) @"&lsquo;", 8216 },
	{ (__block CFStringRef) @"&rsquo;", 8217 },
	{ (__block CFStringRef) @"&sbquo;", 8218 },
	{ (__block CFStringRef) @"&ldquo;", 8220 },
	{ (__block CFStringRef) @"&rdquo;", 8221 },
	{ (__block CFStringRef) @"&bdquo;", 8222 },
	{ (__block CFStringRef) @"&dagger;", 8224 },
	{ (__block CFStringRef) @"&Dagger;", 8225 },
	{ (__block CFStringRef) @"&permil;", 8240 },
	{ (__block CFStringRef) @"&lsaquo;", 8249 },
	{ (__block CFStringRef) @"&rsaquo;", 8250 },
	{ (__block CFStringRef) @"&euro;", 8364 },
};


// Utility function for Bsearching table above
static int EscapeMapCompare(const void *ucharVoid, const void *mapVoid) {
	const unichar *uchar = (const unichar*)ucharVoid;
	const HTMLEscapeMap *map = (const HTMLEscapeMap*)mapVoid;
	int val;
	if (*uchar > map->uchar) {
		val = 1;
	} else if (*uchar < map->uchar) {
		val = -1;
	} else {
		val = 0;
	}
	return val;
}

@implementation NSString (GTMNSStringHTMLAdditions)

- (NSString *)gtm_stringByEscapingHTMLUsingTable:(HTMLEscapeMap*)table 
                                          ofSize:(NSUInteger)size 
                                 escapingUnicode:(BOOL)escapeUnicode {  
	NSUInteger length = [self length];
	if (!length) {
		return self;
	}
	
	NSMutableString *finalString = [NSMutableString string];
	NSMutableData *data2 = [NSMutableData dataWithCapacity:sizeof(unichar) * length];
	
	// this block is common between GTMNSString+HTML and GTMNSString+XML but
	// it's so short that it isn't really worth trying to share.
	const unichar *buffer = CFStringGetCharactersPtr((__bridge CFStringRef)self);
	if (!buffer) {
		// We want this buffer to be autoreleased.
		NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
		if (!data) {
			// COV_NF_START  - Memory fail case
//			_GTMDevLog(@"couldn't alloc buffer");
			return nil;
			// COV_NF_END
		}
		[self getCharacters:[data mutableBytes]];
		buffer = [data bytes];
	}
	
	if (!buffer || !data2) {
		// COV_NF_START
//		_GTMDevLog(@"Unable to allocate buffer or data2");
		return nil;
		// COV_NF_END
	}
	
	unichar *buffer2 = (unichar *)[data2 mutableBytes];
	
	NSUInteger buffer2Length = 0;
	
	for (NSUInteger i = 0; i < length; ++i) {
		HTMLEscapeMap *val = bsearch(&buffer[i], table, 
									 size / sizeof(HTMLEscapeMap), 
									 sizeof(HTMLEscapeMap), EscapeMapCompare);
		if (val || (escapeUnicode && buffer[i] > 127)) {
			if (buffer2Length) {
				CFStringAppendCharacters((__bridge CFMutableStringRef)finalString, 
										 buffer2, 
										 buffer2Length);
				buffer2Length = 0;
			}
			if (val) {
				[finalString appendString:(__bridge  NSString*) (val->escapeSequence)];
			}
			else {
//				_GTMDevAssert(escapeUnicode && buffer[i] > 127, @"Illegal Character");
				[finalString appendFormat:@"&#%d;", buffer[i]];
			}
		} else {
			buffer2[buffer2Length] = buffer[i];
			buffer2Length += 1;
		}
	}
	if (buffer2Length) {
		CFStringAppendCharacters((__bridge CFMutableStringRef)finalString, 
								 buffer2, 
								 buffer2Length);
	}
	return finalString;
}

- (NSString *)gtm_stringByEscapingForHTML {
	return [self gtm_stringByEscapingHTMLUsingTable:gUnicodeHTMLEscapeMap 
											 ofSize:sizeof(gUnicodeHTMLEscapeMap) 
									escapingUnicode:NO];
} // gtm_stringByEscapingHTML

- (NSString *)gtm_stringByEscapingForAsciiHTML {
	return [self gtm_stringByEscapingHTMLUsingTable:gAsciiHTMLEscapeMap 
											 ofSize:sizeof(gAsciiHTMLEscapeMap) 
									escapingUnicode:YES];
} // gtm_stringByEscapingAsciiHTML

- (NSString *)gtm_stringByUnescapingFromHTML {
	NSRange range = NSMakeRange(0, [self length]);
	NSRange subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range];
	
	// if no ampersands, we've got a quick way out
	if (subrange.length == 0) return self;
	NSMutableString *finalString = [NSMutableString stringWithString:self];
	do {
		NSRange semiColonRange = NSMakeRange(subrange.location, NSMaxRange(range) - subrange.location);
		semiColonRange = [self rangeOfString:@";" options:0 range:semiColonRange];
		range = NSMakeRange(0, subrange.location);
		// if we don't find a semicolon in the range, we don't have a sequence
		if (semiColonRange.location == NSNotFound) {
			continue;
		}
		NSRange escapeRange = NSMakeRange(subrange.location, semiColonRange.location - subrange.location + 1);
		NSString *escapeString = [self substringWithRange:escapeRange];
		NSUInteger length = [escapeString length];
		// a squence must be longer than 3 (&lt;) and less than 11 (&thetasym;)
		if (length > 3 && length < 11) {
			if ([escapeString characterAtIndex:1] == '#') {
				unichar char2 = [escapeString characterAtIndex:2];
				if (char2 == 'x' || char2 == 'X') {
					// Hex escape squences &#xa3;
					NSString *hexSequence = [escapeString substringWithRange:NSMakeRange(3, length - 4)];
					NSScanner *scanner = [NSScanner scannerWithString:hexSequence];
					unsigned value;
					if ([scanner scanHexInt:&value] && 
						value < USHRT_MAX &&
						value > 0 
						&& [scanner scanLocation] == length - 4) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
					
				} else {
					// Decimal Sequences &#123;
					NSString *numberSequence = [escapeString substringWithRange:NSMakeRange(2, length - 3)];
					NSScanner *scanner = [NSScanner scannerWithString:numberSequence];
					int value;
					if ([scanner scanInt:&value] && 
						value < USHRT_MAX &&
						value > 0 
						&& [scanner scanLocation] == length - 3) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
				}
			} else {
				// "standard" sequences
				for (unsigned i = 0; i < sizeof(gAsciiHTMLEscapeMap) / sizeof(HTMLEscapeMap); ++i) {
					if ([escapeString isEqualToString:(__bridge NSString*) (gAsciiHTMLEscapeMap[i].escapeSequence)]) {
						[finalString replaceCharactersInRange:escapeRange withString:[NSString stringWithCharacters:&gAsciiHTMLEscapeMap[i].uchar length:1]];
						break;
					}
				}
			}
		}
	} while ((subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range]).length != 0);
	return finalString;
} // gtm_stringByUnescapingHTML



@end