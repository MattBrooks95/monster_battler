module Components.Component where
import Interactions.Interaction (Interaction(..))

class Component a where
	update :: a -> Interaction -> a
	update a interaction = a
