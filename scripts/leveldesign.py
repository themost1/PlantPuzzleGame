
# Use the key below to edit and design the room

room = [
    "GCCCCCCCCCCCCCCG"
    "GCCCCCCCCDCCCCCG"
    "GCCCDCDCDDDDDCCG"
    "GCCDCCDDCCCCDDDG"
    "GGBGDGGBGDGGBGGG"
    "GGBGDGGBGDGGBGGG"
    "GGBDDDDBGDGGBGGG"
    "GGBGGGGBGDGGBGGG"
    "GGBGGGGBDDDDBGGG"
]

key = {
    "B": 'bamboo',
    "C": "cactus",
    "D": "dirt",
    "G": "grass",
    "R": "dragonfruit",
    "N": "dandelion"
}

import json

room = [room[0][i*16:i*16+16] for i in range(9)]
final = []
for r in room:
    l = []
    for c in r:
        l.append(key[c])
    final.append(l)


# COPY AND PASTE OUTPUT directly as the JSON ROOM DATA
    
print("[")
for row in final:
    print('\t',end='')
    print(json.dumps(row), end='')
    print(",")
print("\t],")