import React from 'react'
import { shallow } from 'enzyme'
import TestRenderer from 'react-test-renderer';
import Slideshow from 'packs/postgame/Slideshow'

describe('Slideshow component', () => {
  it('renders', () => {
    const props = {
                    'deck': [
                              'Current_Users__Games_User_Name',
                              {
                                'created_at': "2018-12-09T23:21:04.669Z"
                                'deleted_at': null
                                'description_text': "excellent burnt orange tartan ham"
                                'id': 55
                                'idea_catalyst_id': 19
                                'medium': "description"
                                'out_of_game_card_upload': false
                                'parent_card_id': null
                                'placeholder': false
                                'starting_games_user_id': 19
                                'updated_at': "2018-12-09T23:21:04.985Z"
                                'uploader_id': 1
                              }
                            ],
                            [
                              "Devon Kreiger I",
                              {
                                'created_at': "2018-12-09T23:21:05.257Z"
                                'deleted_at': null
                                'description_text': null
                                'id': 58
                                'idea_catalyst_id': null
                                'medium': "drawing"
                                'out_of_game_card_upload': false
                                'parent_card_id': 55
                                'placeholder': false
                                'starting_games_user_id': 19
                                'updated_at': "2018-12-09T23:21:05.818Z"
                                'uploader_id': 14
                              }
                            ]
                            [
                              "Lincoln Cartwright IV",
                              {
                                'created_at': "2018-12-09T23:21:05.853Z"
                                'deleted_at': null
                                'description_text': "old fashioned jade plaid ant"
                                'id': 62
                                'idea_catalyst_id': null
                                'medium': "description"
                                'out_of_game_card_upload': false
                                'parent_card_id': 58
                                'placeholder': false
                                'starting_games_user_id': 19
                                'updated_at': "2018-12-09T23:21:05.856Z"
                                'uploader_id': 15
                              }
                            ]
                          ]
                      }
    }

    const postgame = shallow(<Slideshow {..props} />)

    expect( postgame.contains('.card') ).toBeDefined();
    // expect( postgame.contains('.card-header .nav-item') ).to.have.lengthOf(2);
    // expect( postgame.contains('.card-header .nav-item:eq(1)') ).to.eq.lengthOf(2);
    expect( postgame.find('.card') ).to.have.lengthOf(1);

  });

  describe('while on the page', ()=>{
    describe('selects a different game in the dropdown selector', ()=>{
      it("", ()=>{
        expect(1).toEqual(1)
      })
    })

    describe('selects the same game in the dropdown selector', ()=>{
      it("doesn't get other ", ()=>{
        expect(1).toEqual(1)

      })
    })
  });

});

// test('adds 1 + 2 to equal 3', () => {
//   expect(1).toEqual(1);
// });
