//==============================================================================
// CPObjectiveInterface
// $wotgreal_dt: 15.04.2014 18:28:11$ by Crusha
//
// Objectives in CP need to extend from a multitude of different classes becaus
// they have very different needs for functionality. That makes it harder to
// have a common base for all of them and requires gameplay code to look at
// them case by case.
// By implementing this interface, the objectives have a common denominator for
// typecasting and calling specific functions on all of them.
//==============================================================================
interface CPObjectiveInterface;