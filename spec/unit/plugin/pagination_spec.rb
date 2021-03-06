require 'spec_helper'

require 'rom/sql/plugin/pagination'

describe 'Plugin / Pagination' do
  include_context 'database setup'

  before do
    9.times { |i| conn[:users].insert(name: "User #{i}") }

    setup.relation(:users) do
      include ROM::SQL::Plugin::Pagination # meh such constants not wow

      per_page 4
    end
  end

  describe '#page' do
    it 'allow to call with stringify number' do
      expect {
        rom.relation(:users).page('5')
      }.to_not raise_error
    end

    it 'preserves existing modifiers' do
      expect(
        rom.relation(:users) { |r| r.where(name: 'User 2') }.page(1).to_a.size
      ).to be(1)
    end
  end

  describe '#per_page' do
    it 'allow to call with stringify number' do
      expect {
        rom.relation(:users).per_page('5')
      }.to_not raise_error
    end

    it 'returns paginated relation with provided limit' do
      users = rom.relation(:users).page(2).per_page(5)

      expect(users.relation.dataset.opts[:offset]).to eql(5)
      expect(users.relation.dataset.opts[:limit]).to eql(5)

      expect(users.pager.current_page).to eql(2)

      expect(users.pager.total).to be(9)
      expect(users.pager.total_pages).to be(2)

      expect(users.pager.next_page).to be(nil)
      expect(users.pager.prev_page).to be(1)
      expect(users.pager.limit_value).to eql(5)
    end
  end

  describe '#pager' do
    it 'returns a pager with pagination meta-info' do
      users = rom.relation(:users).page(1)

      expect(users.pager.total).to be(9)
      expect(users.pager.total_pages).to be(3)

      expect(users.pager.current_page).to be(1)
      expect(users.pager.next_page).to be(2)
      expect(users.pager.prev_page).to be(nil)

      users = rom.relation(:users).page(2)

      expect(users.pager.current_page).to be(2)
      expect(users.pager.next_page).to be(3)
      expect(users.pager.prev_page).to be(1)

      users = rom.relation(:users).page(3)

      expect(users.pager.next_page).to be(nil)
      expect(users.pager.prev_page).to be(2)
    end
  end
end
