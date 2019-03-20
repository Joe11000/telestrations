import React from 'react';
import { mount } from 'enzyme';
import Slideshow from 'packs/postgame/Slideshow';
// import { finished } from 'stream';
import { mock_games_show_request_for_last_postgame } from '../fixtures/mocks/responses/mock_games_show_request_for_last_postgame';

describe('Slideshow component', () => {
  describe('smoke test', () => {
    it('a carousel is on the screen', () => {
      const current_postgame_id = mock_games_show_request_for_last_postgame.PostGameTab.current_postgame_id
      const decks_from_current_postgame = mock_games_show_request_for_last_postgame.PostGameTab.storage_of_viewed_postgames[current_postgame_id];

      const props = { deck: decks_from_current_postgame[0],
                      current_user_info: mock_games_show_request_for_last_postgame.current_user_info }
      const slideshow_component = mount(<Slideshow {...props} />);

      expect(slideshow_component.find('.carousel .carousel-indicators').length).toEqual(1);
      expect(slideshow_component.find('.carousel .carousel-control-prev').length).toEqual(1);
      expect(slideshow_component.find('.carousel .carousel-control-next').length).toEqual(1);
      expect(slideshow_component.find('.carousel .carousel-item').length).toEqual(3);
    });

    it("current_user's card is glowing in each slideshow", () => {
      const current_postgame_id = mock_games_show_request_for_last_postgame.PostGameTab.current_postgame_id
      const decks_from_current_postgame = mock_games_show_request_for_last_postgame.PostGameTab.storage_of_viewed_postgames[current_postgame_id];

      const props_1 = { deck: decks_from_current_postgame[0],
                      current_user_info: mock_games_show_request_for_last_postgame.current_user_info }

      const slideshow_component_1 = mount(<Slideshow {...props_1} />);
      expect(slideshow_component_1.find('.carousel .carousel-item').at(0).hasClass('glow')).toEqual(true);
      expect(slideshow_component_1.find('.carousel .carousel-item').at(1).hasClass('glow')).toEqual(false);
      expect(slideshow_component_1.find('.carousel .carousel-item').at(2).hasClass('glow')).toEqual(false);
    });


    describe('Cards have correct content', () => {
      it("first card has correct content", () => {
        const current_postgame_id = mock_games_show_request_for_last_postgame.PostGameTab.current_postgame_id
        const decks_from_current_postgame = mock_games_show_request_for_last_postgame.PostGameTab.storage_of_viewed_postgames[current_postgame_id];

        const props_1 = { deck: decks_from_current_postgame[0],
                        current_user_info: mock_games_show_request_for_last_postgame.current_user_info }

        const slideshow_component_1 = mount(<Slideshow {...props_1} />);
        const carousel_item = slideshow_component_1.find('.carousel .carousel-item').at(0);
        const description = carousel_item.find('.card-body p').at(0).text();
        const author = carousel_item.find('.card-body p').at(1).text();

        const expected_description = "excellent burnt orange tartan ham";
        const expected_author = "By: Zackary Jaskolski";

        expect(description).toEqual(expected_description);
        expect(author).toEqual(expected_author);
      });

      it('second card has correct content', () => {

        const current_postgame_id = mock_games_show_request_for_last_postgame.PostGameTab.current_postgame_id
        const decks_from_current_postgame = mock_games_show_request_for_last_postgame.PostGameTab.storage_of_viewed_postgames[current_postgame_id];

        const props_2 = { deck: decks_from_current_postgame[0],
                        current_user_info: mock_games_show_request_for_last_postgame.current_user_info }

        const slideshow_component_1 = mount(<Slideshow {...props_2} />);


        const carousel_item = slideshow_component_1.find('.carousel .carousel-item').at(1);
        const url = carousel_item.find('img').prop('src');
        const author = carousel_item.find('p').at(1).text();

        const expected_url = "/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBOZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--0f3f1adfa5d3d579512daee958eacd7b6a98d277/provider_avatar.jpg?disposition=attachment"
        const expected_author = "By: Devon Kreiger I";

        expect(url).toEqual(expected_url);
        expect(author).toEqual(expected_author);
      });

      it("third card has correct content", () => {
        const current_postgame_id = mock_games_show_request_for_last_postgame.PostGameTab.current_postgame_id
        const decks_from_current_postgame = mock_games_show_request_for_last_postgame.PostGameTab.storage_of_viewed_postgames[current_postgame_id];

        const props_3 = { deck: decks_from_current_postgame[0],
                        current_user_info: mock_games_show_request_for_last_postgame.current_user_info }

        const slideshow_component_1 = mount(<Slideshow {...props_3} />);

        const carousel_item = slideshow_component_1.find('.carousel .carousel-item').at(2);
        const description = carousel_item.find('.card-body p').at(0).text();
        const author = carousel_item.find('.card-body p').at(1).text();

        const expected_description = "old fashioned jade plaid ant";
        const expected_author = "By: Lincoln Cartwright IV";

        expect(description).toEqual(expected_description);
        expect(author).toEqual(expected_author);
      });
    })
  })
});
