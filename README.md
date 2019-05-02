# Create naturally-growing trees from any material

## Screenshots:

![Screenshot 1](https://i.imgur.com/LD6VcO1.jpg)

![Screenshot 2](https://i.imgur.com/p263ejK.jpg)

## How to use:

Place one of the `rnd_trees` blocks. The tree will start growing immediately.

Blocks are:
- `rnd_trees:tree` - customizable growth pattern/materials
- `rnd_trees:aspentree` - roughtly equivalent to the default aspen tree
- `rnd_trees:pinetree` - approximate size/shape of default pine tree. The growth algorithm is best suited to deciduous tres, so it doesn't resemble the default version very well
- `rnd_trees:jungletree` - closely resembles the default jungle tree; can be as tall as an emergent jungle tree
- `rnd_trees:appletree` - a larger and more realistic apple tree
- `rnd_trees:acaciatree` - roughtly equivalent to the default acacia tree. Again, the growth algorithm does not work as well for this one

## Chat commands:
- `/trunkmat` - the trunks of all future trees grown from `rnd_trees:tree` will be made of the currently wielded block
- `/leafmat` - the leaves of all future trees grown from `rnd_trees:tree` will be made of the currently wielded block
- `/treespec <height> <trunk height> <branch length>` - all future trees grown from `rnd_trees:tree` will have an overall height of <height> blocks, branches starting above <trunk height> blocks and branches up to <branch length> blocks long.
Any of these values may be made negative to randomize the value near the given value; e.g. `/treespec -30 5 10` will cause future trees to be a random height near 30 blocks

Customizations are per user and persist across logins.
