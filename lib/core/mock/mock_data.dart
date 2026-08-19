// Hardcoded placeholder data so the first screens have something real to
// render before the corresponding API modules are wired up. Delete/replace
// call sites with real repository calls module by module — nothing here is
// meant to persist once `/api/projects`, `/api/leads` etc. are connected.

class MockProject {
  const MockProject({
    required this.name,
    required this.builder,
    required this.location,
    required this.priceRange,
    required this.bhkOptions,
    required this.commissionRate,
    required this.reraVerified,
  });

  final String name;
  final String builder;
  final String location;
  final String priceRange;
  final List<String> bhkOptions;
  final String commissionRate;
  final bool reraVerified;
}

const mockHotProjects = [
  MockProject(
    name: 'Lodha World Towers',
    builder: 'Lodha Group',
    location: 'Lower Parel, Mumbai',
    priceRange: '₹5.5 Cr+',
    bhkOptions: ['3 BHK', '4 BHK'],
    commissionRate: '3.0%',
    reraVerified: true,
  ),
  MockProject(
    name: 'Godrej Exquisite',
    builder: 'Godrej Properties',
    location: 'Thane West',
    priceRange: '₹1.8 Cr - 3.4 Cr',
    bhkOptions: ['2 BHK', '3 BHK'],
    commissionRate: '4.0%',
    reraVerified: true,
  ),
  MockProject(
    name: 'Piramal Aranya',
    builder: 'Piramal Realty',
    location: 'Byculla, Mumbai',
    priceRange: '₹3.2 Cr - 5.8 Cr',
    bhkOptions: ['3 BHK'],
    commissionRate: '3.5%',
    reraVerified: true,
  ),
];

const mockHighCommissionProjects = [
  MockProject(
    name: 'M3M Golf Hills',
    builder: 'M3M Group',
    location: 'Sector 79, Gurugram',
    priceRange: '₹1.85 Cr - 2.15 Cr',
    bhkOptions: ['3 BHK'],
    commissionRate: '4.5%',
    reraVerified: true,
  ),
  MockProject(
    name: 'Prestige High Lines',
    builder: 'Prestige Estates',
    location: 'Whitefield, Bengaluru',
    priceRange: '₹1.6 Cr - 2.4 Cr',
    bhkOptions: ['2 BHK', '3 BHK'],
    commissionRate: '4.2%',
    reraVerified: false,
  ),
];

class MockLead {
  const MockLead({
    required this.clientName,
    required this.project,
    required this.status,
    required this.registeredAt,
  });

  final String clientName;
  final String project;
  final String status;
  final String registeredAt;
}

const mockLeads = [
  MockLead(clientName: 'Aditya Roy', project: 'Godrej Exquisite', status: 'New', registeredAt: '12 Oct 2026'),
  MockLead(clientName: 'Vikram Malhotra', project: 'Lodha World Towers', status: 'Site Visit', registeredAt: '10 Oct 2026'),
  MockLead(clientName: 'Meera Sen', project: 'Piramal Aranya', status: 'Negotiation', registeredAt: '05 Oct 2026'),
  MockLead(clientName: 'Siddharth Jain', project: 'M3M Golf Hills', status: 'Contacted', registeredAt: '02 Oct 2026'),
];
