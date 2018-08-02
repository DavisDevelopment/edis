package edis.dom.components;

interface IInput<T> {
    function getValue():T;
    function setValue(v: T):Void;
}
