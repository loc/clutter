//
//  event.h
//  Clutter
//
//  Created by Andy Locascio on 10/5/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

enum Event {
    modified = 1 << 0,
    created = 1 << 1,
    renamed = 1 << 2,
    deleted = 1 << 3,
    accessed = 1 << 4
};

enum Command {
    openPanel = 1 << 0,
    closePanel = 2 << 1,
    refreshPanel = 1 << 2
};