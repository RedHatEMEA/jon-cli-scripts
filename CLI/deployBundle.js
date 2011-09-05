//Params Required: bundleName
//Params Optional: deploymentDesc
//Usage: deployBundle.js 		
//Description: Deploys a bundle using the specified bundleName and optionally a deployment description to be used
rhq.login('rhqadmin', 'rhqadmin');

var bundleName = args[0];
var deploymentDesc = args[1];

if (args.length < 1 || bundleName == "") {
	println("You need to provide the bundle name to deploy the bundle");
} else {

	if (deploymentDesc.isEmpty()) {
		deploymentDesc = "Deployment triggered by CLI script";
	}

	//Find the bundle
	var criteria = new BundleCriteria();
	criteria.addFilterName(bundleName);
	criteria.fetchBundleVersions(true);
	var bundleArray = BundleManager.findBundlesByCriteria(criteria);

	if (!bundleArray.isEmpty()) {
		var bundle = bundleArray.get(bundleArray.totalSize - 1);

		//Get the bundle id to be used
		var bundleId = bundle.id;
		println("Found the bundle " + bundleName + " with id: " + bundleId);
		var bundleVersions = bundle.getBundleVersions();
		var bundleVersion = bundleVersions.get(bundleVersions.size() - 1);
		println("Using version [" + bundleVersion.version + "] of the bundle");

		//Find the destination
		var bdc = new BundleDestinationCriteria();
		bdc.addFilterBundleId(bundleId);
		var destinations = BundleManager.findBundleDestinationsByCriteria(bdc);

		if (destinations.totalSize > 0) {
			var destination = destinations.get(destinations.totalSize - 1);
			println("Found the destination " + destination.name);
	
			// create a config for the V1.0 deployment
			// setting the required properties for recipe in distro
			var config1 = new Configuration();
			var property11 = new PropertySimple("instance", "default");
			config1.put( property11 );
			var property12 = new PropertySimple("java-home", "/opt/jdk1.6.0_26");
			config1.put( property12 );
			var property13 = new PropertySimple("port-set", "03");
			config1.put( property13 );
			var property14 = new PropertySimple("bind-address", "127.0.0.1");
			config1.put( property14 );

			var deployment = BundleManager.createBundleDeployment(bundleVersion.getId(), destination.getId(), deploymentDesc, config1);
			deployment = BundleManager.scheduleBundleDeployment(deployment.getId(), true);
			println("Deployment completed.");
		} else {
			println("The bundle does not have a destination and cannot be deployed.");
		}
	} else {
		println("The bundle with name " + bundleName + " does not exist in the system.");
	}
}

rhq.logout();
