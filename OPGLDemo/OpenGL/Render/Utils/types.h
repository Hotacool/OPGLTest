//
//  types.h
//  OPGLDemo
//
//  Created by Hotacool on 2020/3/24.
//  Copyright © 2020 Hotacool. All rights reserved.
//

#ifndef types_h
#define types_h

struct
RGBA {
    float r;  // Red component (0 <= r <= 1)
    float g;  // Green component (0 <= g <= 1)
    float b;  // Blue component (0 <= b <= 1)
    float a;  // Alpha/opacity component (0 <= a <= 1)
};
typedef struct RGBA RGBA;

#endif /* types_h */
