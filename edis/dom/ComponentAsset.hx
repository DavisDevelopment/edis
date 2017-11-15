package edis.dom;

import tannus.ds.Destructible;

/**
  * Interface for an object which can be 'attached' to a Widget
  */
interface ComponentAsset extends Destructible {
	function activate():Void;
}
