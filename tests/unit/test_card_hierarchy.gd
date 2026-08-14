extends GutTest

func test_card_digimon_reads_fields_from_data() -> void:
	var card := CardDigimon.new({
		"_id": "id-1", "price": 3, "name": "TestMon", "type": DB.CARD_TYPE.DIGIMON,
		"color": DB.COLORS_CARD.RED, "attackPoints": 10, "healthPoints": 20,
		"energyCount": 1, "evolution": null, "level": 1,
	})
	assert_eq(card.id, "id-1")
	assert_eq(card.price, 3)
	assert_eq(card.name, "TestMon")
	assert_eq(card.attackPoints, 10)
	assert_eq(card.healthPoints, 20)

func test_card_equipment_reads_fields_from_data() -> void:
	var card := CardEquipment.new({
		"_id": "id-2", "price": 2, "name": "TestGear", "type": DB.CARD_TYPE.EQUIPMENT,
		"attackPoints": 5, "healthPoints": 0, "targetScope": "UNIQUE", "quantityOfTargets": 1,
	})
	assert_eq(card.id, "id-2")
	assert_eq(card.attackPoints, 5)
	assert_true(card.description.length() > 0)

func test_card_energy_reads_fields_from_data() -> void:
	var card := CardEnergy.new({
		"_id": "id-3", "price": 1, "name": "TestEnergy", "type": DB.CARD_TYPE.ENERGY,
		"color": DB.COLORS_CARD.BLUE, "energyCount": 2,
	})
	assert_eq(card.id, "id-3")
	assert_eq(card.energyCount, 2)

func test_card_summon_digimon_does_not_initialize_base_fields() -> void:
	# Bug conocido (ver SPEC.md §8): CardSummonDigimon._init no llama a super._init(card_data),
	# así que id/price/name/type quedan sin inicializar. Este test queda en rojo a propósito
	# hasta que se corrija _init en domain/card_summon_digimon.gd.
	var card := CardSummonDigimon.new({
		"_id": "id-4", "price": 1, "name": "Summon Test x2", "type": DB.CARD_TYPE.SUMMON_DIGIMON,
		"digimonsCards": [],
	})
	assert_eq(card.id, "id-4", "id debería quedar seteado por super._init, pero el bug conocido lo deja vacío")
	assert_eq(card.name, "Summon Test x2")
