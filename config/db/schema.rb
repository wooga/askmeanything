# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190301150506) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "questions", force: :cascade do |t|
    t.text     "question"
    t.integer  "round_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "questioner"
  end

  add_index "questions", ["round_id"], name: "index_questions_on_round_id", using: :btree

  create_table "rounds", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "deadline"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "state",       default: "active"
    t.text     "salt"
    t.text     "owner"
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "vote"
    t.integer  "question_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "hashed_mail"
  end

  add_index "votes", ["hashed_mail", "question_id"], name: "index_votes_on_hashed_mail_and_question_id", unique: true, using: :btree
  add_index "votes", ["question_id"], name: "index_votes_on_question_id", using: :btree

end
