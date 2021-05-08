# Eniko

Eniko is an implementation of a simple, decentralized, transparent and open nation written in Solidity for Ethereum blockchains. It is built on the principle of meeting the needs of its citizens under the guidance of a single purpose. This purpose is then expanded by the citizens by adding conseuqences to form a tree.

Further details on the principle of Eniko and a basic implementation of a user interface can be found at [Project Eniko](https://projecteniko.com/).

Eniko is a community project. Developers are welcome to join the development team and contribute towards its development.

Eniko's structure consists of a root contract, Eniko, and a set up functional data storage contracts known as Eniko Apps. Functional and data storage contracts are seperated so that functional contracts can be re-deployed without needing to re-deploy the underlying data.

The root [Eniko](https://github.com/ProjectEniko/eniko/wiki/Eniko) contract is currently deployed on Ropsten at address 0xF87C6311EA1DbE9178407E6E345d772aaDdAecb4. The address which deployed the Eniko contract is known as the Founder.

The Eniko Apps are stored in an array in the Eniko contract. Some have fixed indices although it is expected that more apps will be added later to meet the needs of citizens. Fixed app indices are:

0 = Null - Used as a safe value

1 = CitizenNeedsFunctions - A set of functions to enable citizens to declare their needs and for others to provide solutions to them. NOT YET IMPLEMENTED.

2 = NeedDeployer - A deployment helper contract which enables the CitizenNeedsFunctions contract to create Need contracts. NOT YET IMPLEMENTED.

3 = SolutionDeployer - A deployment helper contract which enables the CitizenNeedsFunctions contract to create Solution contracts. NOT YET IMPLEMENTED.

4 = [ConsequenceFunctions](https://github.com/ProjectEniko/eniko/wiki/ConsequenceFunctions) - A set of functions to enable citizens to add consequences to the purpose and read and edit consequences.

5 = [ConsequenceDeployer](https://github.com/ProjectEniko/eniko/wiki/ConsequenceDeployer) - A deployment helper contract which enables the ConsequenceFunctions contract to create Consequence contracts.

6 = null

7 = [BallotFunctions](https://github.com/ProjectEniko/eniko/wiki/BallotFunctions) - A set of functions to enable citizens to read Ballots and, where allowed, vote in them. Currently only the Founder can create Ballots although eventually only the CitizenNeedsFunctions contract will be able to do so.

8 = [BallotDeployer](https://github.com/ProjectEniko/eniko/wiki/BallotDeployer) - A deployment helper contract which enables the BallotFunctions contract to create Consequence contracts.

9 = [BallotList](https://github.com/ProjectEniko/eniko/wiki/BallotList) - A storage contract which contains a list of the addresses of all Ballots ever created.

10 = [CitizenFunctions](https://github.com/ProjectEniko/eniko/wiki/CitizenFunctions) - A set of functions to enable citizens to access the friendly name and public key of other citizens and to edit their own.

11 = [Citizens](https://github.com/ProjectEniko/eniko/wiki/Citizens) - A storage contract which contains a friendly name and a public key corresponding to the addresses of citizens. The public key is used to encrypt private Consequence contracts.

12 = MessagingFramework - A framework under which citizens are able to communicate with each other. NOT YET IMPLEMENTED.

To ease early development the Founder is able to replace Eniko Apps until the date 2.2.22. After 2.2.22 Eniko Apps can only be replaced by a Ballot. At this point Eniko will be fully autonomous.

In addition to Eniko Apps [Consequence](https://github.com/ProjectEniko/eniko/wiki/Consequence) and [Ballot](https://github.com/ProjectEniko/eniko/wiki/Ballot) contracts are also included which each store details of a single consequence or ballot and can be discovered using the ConsequenceFunctions and BallotFunctions contracts respectively.

A library [Alexandria](https://github.com/ProjectEniko/eniko/wiki/Alexandria) is also included for convenience and a contract [EnikoApp](https://github.com/ProjectEniko/eniko/wiki/EnikoApp) provides common basic required functionality for all Eniko Apps.

# Contract Implementations
Full details of contract implementations can be found on the [Wiki](https://github.com/ProjectEniko/eniko/wiki).


# Contributing
Pull requests are welcome. For major changes, please open an [issue](https://github.com/ProjectEniko/eniko/issues0) first to discuss what you would like to change.

A full list of open projects can be found on the [Projects page](https://github.com/ProjectEniko/eniko/projects). We welcome all offers to contribute towards these projects.

# License
[GNU General Public License ](https://www.gnu.org/licenses/gpl-3.0.en.html/)
