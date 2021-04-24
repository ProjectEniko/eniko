const bytes32 = require('bytes32');

/*
const Eniko = artifacts.require("Eniko");

module.exports = function (deployer) {
  deployer.deploy(Eniko);
};
//*/

/*
// Full Deployment
const Eniko = artifacts.require("Eniko");
//const CitizenNeedsFunctions = artifacts.require("CitizenNeedsFunctions");
//const NeedDeployer = artifacts.require("NeedDeployer");
//const SolutionDeployer = artifacts.require("SolutionDeployer");
const ConsequenceFunctions = artifacts.require("ConsequenceFunctions");
const PurposeConsequenceDeployer = artifacts.require("PurposeConsequenceDeployer");
const ConsequenceDeployer = artifacts.require("ConsequenceDeployer");
const BallotFunctions = artifacts.require("BallotFunctions");
const BallotDeployer = artifacts.require("BallotDeployer");
const BallotList = artifacts.require("BallotList");
const CitizenFunctions = artifacts.require("CitizenFunctions");
const Citizens = artifacts.require("Citizens");
//const MessagingFramework = artifacts.require("ConsequenceFunctions");

module.exports = function (deployer) {
  deployer.deploy(Eniko)
  //.then(() => deployer.deploy(CitizenNeedsFunctions, Eniko.address) )
  //.then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(1, CitizenNeedsFunctions.address) ))
  //.then(() => deployer.deploy(NeedDeployer, Eniko.address) )
  //.then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(2, NeedDeployer.address) ))
  //.then(() => deployer.deploy(SolutionDeployer, Eniko.address) )
  //.then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(3, SolutionDeployer.address) ))
  .then(() => deployer.deploy(ConsequenceFunctions, Eniko.address) )
  .then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(4, ConsequenceFunctions.address) ))
  // Deploy the PurposeConsequenceCreator instead of ConsequenceCreator to begin with
  .then(() => deployer.deploy(PurposeConsequenceDeployer, Eniko.address) )
  .then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(5, PurposeConsequenceDeployer.address) ))
  // Set the purpose
  .then(() => PurposeConsequenceDeployer.deployed().then( (instance) => instance.createPurpose("Maximise Happiness from Now until the End of Time",
  "Our+single+purpose+is+to+maximise+happiness+across+our+planet+from+now+until+the+end+of+time.%0D%0A%0D%0ABut+what+is+happiness%3F+It%27s+very+subjective+so+let%27s+try+to+be+more+specific.+We+define+happiness+as+pleasure+minus+pain.+This+is+a+good+step%2C+but+we+need+to+go+further+to+define+what+we+mean+by+pleasure+and+pain.+To+do+that+we+take+a+cellular+view.%0D%0A%0D%0ALife+is+made+up+of+cells.+Life+on+Earth+is+the+sum+of+all+the+cells+on+the+planet.%0D%0A%0D%0ACells+can+only+survive+if+they+are+able+to+maintain+an+optimal+steady+state.+This+state+includes+many+different+factors+such+as+chemical+balances%2C+electrical+potentials%2C+temperature+and+fluids.+Maintaining+it+requires+energy.+If+any+of+these+factors+deviate+from+the+optimal+state%2C+the+cell+will+start+to+malfunction+and+eventually+die.%0D%0A%0D%0AThe+result+of+millennia+of+evolution+is+that+all+cells+today%2C+including+our+own%2C+are+very+good+at+maintaining+their+optimal+state.%0D%0A%0D%0ATo+some+extent+cells+can+maintain+their+state+on+their+own.+But+it+turns+out+that+many+of+the+cells+that+are+doing+the+best+out+of+the+evolutionary+process+are+the+ones+that+have+managed+to+work+together.+These+cells+stay+alive+longer+by+helping+each+other.+Working+together+relies+on+a+notification+system+and+an+incentive+system.+The+notification+system+declares+that+a+cell+is+not+in+its+optimal+state.+The+second+system+incentivises+anything+that+brings+cells+back+towards+their+optimal+state.%0D%0A%0D%0AThese+systems+are+how+we+will+define+pain+and+pleasure.+We+define+pain+as+the+result+of+a+cell+not+being+in+its+optimal+state+and+we+define+pleasure+as+the+result+of+a+cell+moving+towards+its+optimal+state.+Pain+can+never+be+negative%3B+a+cells+state+can+never+be+more+optimal+than+optimal.+We+also+assume+the+pleasure+can+not+be+negative%3B+when+a+cells+state+is+moving+away+from+optimal+pleasure+is+zero+and+when+it+is+moving+towards+optimal+pleasure+is+positive.%0D%0A%0D%0AThis+may+not+correspond+exactly+to+our+notions+of+human+happiness%2C+pleasure+and+pain.+Not+all+cells+have+evolved+into+groups%2C+and+those+that+have+done+have+evolved+different+mechanisms+for+communicating+amongst+themselves.+The+way+that+we+experience+changes+in+our+cell+state+is+probably+very+different+to+the+way+that+an+oak+tree+experiences+changes+in+its+cell+state.+There+are+even+differences+from+one+human+to+another.+Our+own+experience+of+pain+and+pleasure+is+very+subjective.+Here+we+will+treat+all+cells+as+equal+by+considering+pain+and+pleasure+purely+as+definitions+of+the+state+and+change+in+state+of+a+cell.%0D%0A%0D%0AIf+we+were+to+go+one-by-one+to+every+cell+on+the+planet%2C+we+could+calculate+its+happiness+by+measuring+the+difference+between+its+current+state+and+its+optimal+state%2C+its+pain%2C+and+then+subtracting+this+from+the+rate+at+which+its+state+is+moving+towards+optimal%2C+its+pleasure.+We+could+then+add+up+the+results+from+all+the+cells+to+get+a+global+happiness+score.+Our+objective+would+then+be+to+maximise+this+global+happiness+score+between+now+and+the+end+of+time.%0D%0A%0D%0AOf+course+it%27s+not+possible+to+measure+the+state+of+every+cell+on+the+planet.+Whilst+this+level+of+detail+is+important+to+bring+objectivity+to+our+purpose%2C+it+does+not+take+away+from+the+fact+that+the+aim+is+to+maximise+happiness+across+our+planet+from+now+until+the+end+of+time."
  ) ))
  // Get the purpose address and save it in Eniko
  .then(() => PurposeConsequenceDeployer.deployed().then( (instance) => instance.getPurposeAddress.call() ).then( (getPurposeAddress) => Eniko.deployed().then( (instance) => instance.setPurpose(getPurposeAddress) ) ))
  // Deploy the real ConsequenceCreator and set it in Eniko (this will destroy the PurposeConsequenceDeployer)
  .then(() => deployer.deploy(ConsequenceDeployer, Eniko.address) )
  .then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(5, ConsequenceDeployer.address) ))
  .then(() => deployer.deploy(BallotFunctions, Eniko.address) )
  .then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(7, BallotFunctions.address) ))
  .then(() => deployer.deploy(BallotDeployer, Eniko.address) )
  .then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(8, BallotDeployer.address) ))
  .then(() => deployer.deploy(BallotList, Eniko.address) )
  .then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(9, BallotList.address) ))
  .then(() => deployer.deploy(CitizenFunctions, Eniko.address) )
  .then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(10, CitizenFunctions.address) ))
  .then(() => deployer.deploy(Citizens, Eniko.address) )
  .then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(11, Citizens.address) ))
  //.then(() => deployer.deploy(MessagingFramework, Eniko.address) )
  //.then(() => Eniko.deployed().then( (instance) => instance.updateAppAddress(12, MessagingFramework.address) ))
  ;
};
//*/

/*
// Update ConsequenceFunctions
const ConsequenceFunctions = artifacts.require("ConsequenceFunctions");

module.exports = function (deployer) {
  deployer.deploy(ConsequenceFunctions, '0xF87C6311EA1DbE9178407E6E345d772aaDdAecb4')
};
//*/

/*
// Update ConsequenceDeployer
const ConsequenceDeployer = artifacts.require("ConsequenceDeployer");

module.exports = function (deployer) {
  deployer.deploy(ConsequenceDeployer, '0xF87C6311EA1DbE9178407E6E345d772aaDdAecb4')
};
//*/

//*
// Update BallotFunctions
const BallotFunctions = artifacts.require("BallotFunctions");

module.exports = function (deployer) {
  deployer.deploy(BallotFunctions, '0xF87C6311EA1DbE9178407E6E345d772aaDdAecb4')
};
//*/

/*
// Update CitizenFunctions
const CitizenFunctions = artifacts.require("CitizenFunctions");

module.exports = function (deployer) {
  deployer.deploy(CitizenFunctions, '0xF87C6311EA1DbE9178407E6E345d772aaDdAecb4')
};
//*/

/*
const Dummy = artifacts.require("Dummy");

module.exports = function (deployer) {
  deployer.deploy(Dummy);
};
//*/


