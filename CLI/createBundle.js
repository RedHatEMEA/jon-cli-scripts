//Params Required: bundleZipFile
//Usage: createBundle.js 		##Creates a bundle version using the specified file
rhq.login('rhqadmin', 'rhqadmin');

var fileName = args[0];
var groupName = "";

if (args.length < 1 || fileName == "") {
	println("You need to provide the bundle file name to create generate your bundle...");
} else {

//TODO do look for bundle and then use
//	criteria.fetchBundleVersions(true);
//	but how to figure out the version of the bundle being uploaded.. read what's in file??

	//Create bundle version
	var file = new java.io.File(fileName);

/*
	var locationOfZip = file.name.indexOf(".zip");
	var bundleName = file.name.substring(0, locationOfZip); 

	if (!bundleName.isEmpty()) {
		var criteria = new BundleCriteria();
		criteria.addFilterName(bundleName);
		criteria.fetchBundleVersions(true);
		var bundleArray = BundleManager.findBundlesByCriteria(criteria);
	}
	
	if (!bundleArray.isEmpty()) {
*/
	var bundle = BundleManager.createBundleVersionViaFile(file);
	println("Bundle " + bundle.name + " has been created.");

}

rhq.logout();