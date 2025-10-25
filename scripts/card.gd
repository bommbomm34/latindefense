# Implementation of the SM-2 algorithm
class_name Card
extends Node

const FORMAT = "{0}|{1}|{2}|{3}|{4}|{5}"
var question := ""
var answer := ""
var repetition_number := 0
var easiness_factor := 2.5
var interval := 0
var next_review = Time.get_unix_time_from_system()

static func deserialize(serial: String) -> Card:
	var array := serial.split("|")
	var card := Card.new(array[0], array[1])
	card.repetition_number = int(array[2])
	card.easiness_factor = float(array[3])
	card.interval = int(array[4])
	card.next_review = float(array[5])
	
	return card

func _init(given_question: String, given_answer: String):
	question = given_question
	answer = given_answer

func serialize() -> String:
	return FORMAT.format([question, answer, repetition_number, easiness_factor, interval, next_review])

func needs_review() -> bool:
	return next_review <= Time.get_unix_time_from_system()

func review(user_grade: float):
	if user_grade >= 3:
		if repetition_number == 0:
			interval = 1
		elif repetition_number == 1:
			interval = 6
		else:
			interval = round(interval * easiness_factor)
		repetition_number += 1
	else:
		repetition_number = 0
		interval = 1
	
	next_review = get_date_after_days(interval)
	easiness_factor += (0.1 - (5 - user_grade) * (0.08 + (5 - user_grade) * 0.02))
	# Easiness factor can't be below 1.3
	easiness_factor = max(easiness_factor, 1.3)
	next_review = get_date_after_days(interval)

func get_date_after_days(days: int) -> float:
	var today = Time.get_unix_time_from_system()
	var after_days = ceilf(today / 86400) * 86400 + days * 86400
	return today if days == 0 else after_days
