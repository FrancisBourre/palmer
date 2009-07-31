package net.pixlib.core
{
	/**
	 * @author Francis Bourre
	 */
	public interface CoreFactoryListener
	{
		function onRegisterBean		( e : CoreFactoryEvent ) : void;
		function onUnregisterBean	( e : CoreFactoryEvent ) : void;
	}
}