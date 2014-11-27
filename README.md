# Point of Sale using lua for Computer craft

In order to run an effective shop, a custommer must find it easy purchase items. This computer craft software should enable a player to set up a shop that allows multiple items to be sold for prices that are governed by the 'value' of items that the shop keeper can set.

## Requirements

This uses the following setup:

* one POS computer node 
  * has a 4x3 set of monitors attached above
  * has a modem attached at the rear
* four slave "shelves" that are within the same chunk running the turtle software.
  * each shelf must have a wireless modem attached at the back
  * for the armour set up, have a chest above, below to the right and left of the turtle containing one piece of the armour. Sets must be complete.
  * an output to the front to the customer
* a cashier turtle which to be written

## Releases

Once a release is suitable for release, I will release each file to pastebin and detail the hashes for download to relevent turtles/computers.

There are no current releases as this software is in progress

## TODO

* Finalise refactor
* Allow purchase message to flow to shelf and back
* Method for determining stock (when and where)
* Write cashier system
  * Calculate value of items in "payment"
  * Lock "payment" whilst stock is delivered
  * Return "payment" if purchase fails
  * Store "payment" on success
* Create delevery mechanism for items
* Create payment system for "payment"
* Refactor to make customisation easier
* ...
* profit
