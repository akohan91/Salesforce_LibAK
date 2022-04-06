List<Contact> cons = new List<Contact>();

for (Integer i = 0; i < 10; i++) {
    cons.add(new Contact(
        FirstName = 'FiersName' + ' ' + i,
        LastName = 'LastName' + ' ' + i
    ));
}

Database.insert(cons);