package egovframework.coviaccount.config;

import java.util.Arrays;
import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.oas.annotations.EnableOpenApi;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.ApiKey;
import springfox.documentation.service.AuthorizationScope;
import springfox.documentation.service.SecurityReference;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spi.service.contexts.OperationModelContextsBuilder;
import springfox.documentation.spi.service.contexts.SecurityContext;
import springfox.documentation.spring.web.plugins.Docket;

@Configuration
//@EnableSwagger2
@EnableWebMvc
@EnableOpenApi
public class SwaggerConfig implements WebMvcConfigurer {

	@Bean
	public Docket api() {
//		SecurityScheme securityScheme = new SecurityScheme()
//				.type(SecurityScheme.Type.HTTP).scheme("bearer").bearerFormat("JWT")
//				.in(SecurityScheme.In.HEADER).name("Authorization");		
//		SecurityRequirement schemaRequirement = new SecurityRequirement().addList("bearerAuth");
		return new Docket(DocumentationType.OAS_30)
                .securityContexts(Arrays.asList(securityContext())) // 추가
                .securitySchemes(Arrays.asList(apiKey())) // 추가
				.apiInfo(apiInfo())
				.select()
				.apis(RequestHandlerSelectors.basePackage("egovframework.coviaccount.api.slip"))
				.paths(PathSelectors.any())
				.build();
		
//		return new OpenAPI()
//				.components(new Components().addSecuritySchemes("bearerAuth", securityScheme))
//				.security(Arrays.asList(schemaRequirement)
//				.securitySchemes(Arrays.asList(apiKey()))
//				.info(apiInfo());
	}

	private ApiInfo apiInfo() {
		return new ApiInfoBuilder()
				.title("e-Accounting API")
				.description("e-Accounting API 목록 및 테스트를 위한 swagger입니다.")
				.version("1.0")
				//.license(new License().name("Apache License Version 2.0").url("http://www.apache.org/licenses/LICENSE-2.0"));
				.license("Apache License Version 2.0")
				.licenseUrl("http://www.apache.org/licenses/LICENSE-2.0")
				.build();
	}

    private SecurityContext securityContext() {
        return SecurityContext.builder()
                .securityReferences(defaultAuth())
                .build();
    }
    
    private List<SecurityReference> defaultAuth() {
        AuthorizationScope authorizationScope = new AuthorizationScope("global", "accessEverything");
        AuthorizationScope[] authorizationScopes = new AuthorizationScope[1];
        authorizationScopes[0] = authorizationScope;
        return Arrays.asList(new SecurityReference("Authorization", authorizationScopes));
    }
    
	private ApiKey apiKey() {
        return new ApiKey("Authorization", "Authorization", "header");
    }
	
	
	@Override 
	public void addResourceHandlers(ResourceHandlerRegistry registry) {
		registry.addResourceHandler("/swagger-ui/**")
			.addResourceLocations("classpath:/META-INF/resources/webjars/springfox-swagger-ui/");

		registry.addResourceHandler("/webjars/**")
			.addResourceLocations("classpath:/META-INF/resources/webjars/"); 
	}

	@Override
	public void addViewControllers(ViewControllerRegistry registry) {
		registry.addViewController("/swagger-ui/")
			.setViewName("forward:" + "/swagger-ui/index.html");
	}
}