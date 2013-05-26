class eAnimNodeSequencePlayFromStart extends AnimNodeSequence;

 

var() bool bPlayFromStart;

event OnBecomeRelevant() {

 if (bPlayFromStart)  {

SetPosition(0.0f, false);

 }

 }

defaultproperties {

bPlayFromStart=true;
bCallScriptEventOnBecomeRelevant=TRUE

}