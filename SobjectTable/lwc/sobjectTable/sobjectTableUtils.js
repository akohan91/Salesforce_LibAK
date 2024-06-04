/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */

/**
 * Makes the Sobject record in flatten format.
 * @param {Object}   record - Sobject record
 * @param {String[]} addressFieldsList - List of fields that have ADDRESS field type
 * @param {String[]} referenceFieldPathList - List of fields that have REFFERENCE field type
 * @returns {Object}
 */
const flattenForDataTable = (record, addressFieldsList = [], referenceFieldPathList = []) => {
	let result = {};
	const recurse = (recordValue, fieldPath) => {
		fieldPath = fieldPath.toLowerCase();
		if (Object(recordValue) !== recordValue) { // Check is the record value not Object
			result[fieldPath] = recordValue;
			referenceFieldPathList.includes(fieldPath) && (result[fieldPath + '_link'] = '/' + recordValue);
		} else if (addressFieldsList.includes(fieldPath)) {
			result[fieldPath] = Object.values(recordValue).join('; ');
		} else {
			let isEmpty = true;
			for (let p in recordValue) {
				isEmpty = false;
				recurse(recordValue[p], fieldPath ? fieldPath + "." + p : p);
			}
			if (isEmpty && fieldPath) {
				result[fieldPath] = {};
			}
		}
	}

	recurse(record, "");
	return result;
}

/**
 * Used to override, add, or remove columns. Structure of object
 * @param {Object[]} currentColumns
 * @param {Object[]} columnsToOverride
 * {
 *      action: { String}, 'ADD' | 'REMOVE' | 'OVERRIDE'
 *      fieldName: { String }, name of field (column), used for 'REMOVE' and 'OVERRIDE' actions
 *      column: { Object }, used for 'ADD' and 'OVERRIDE' actions
 * }
 * @returns {Object[]} - new version of columns list
 */
 const overrideDataTableColumns = (currentColumns = [], columnsToOverride = []) => {
	columnsToOverride.forEach(item => {
		switch (item.action) {
			case 'ADD':
				currentColumns.push(item.column);
				break;
			case 'REMOVE':
				currentColumns = currentColumns.filter(existColumn => {
					if (!existColumn.fieldName) {
						return true;
					} else {
						return existColumn.fieldName.toLowerCase() !== item.fieldName.toLowerCase()
					}
				})
				break;
			case 'OVERRIDE':
				currentColumns = [...currentColumns.map(existColumn => {
					if (existColumn.fieldName && existColumn.fieldName.toLowerCase() === item.fieldName.toLowerCase()) {
						return {...existColumn, ...item.column}
					} else {
						return existColumn;
					}
				})]
				break;
		}
	});
	return currentColumns;
}

export {
	flattenForDataTable,
	overrideDataTableColumns
}